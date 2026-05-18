import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../jobs/domain/job_model.dart';
import '../../domain/applied_job_model.dart';

const _appliedJobsStorageKey = 'applied_jobs_v1';

/// Job queued for apply after the user completes login.
final pendingApplyJobProvider = StateProvider<JobModel?>((ref) => null);

final appliedJobsProvider =
    StateNotifierProvider<AppliedJobsNotifier, AsyncValue<List<AppliedJobModel>>>(
      (ref) => AppliedJobsNotifier(),
    );

class AppliedJobsNotifier extends StateNotifier<AsyncValue<List<AppliedJobModel>>> {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appsSub;

  AppliedJobsNotifier() : super(const AsyncValue.loading()) {
    if (AppConfig.isFirebaseEnabled) {
      _authSub = _auth.authStateChanges().listen((_) => _subscribeApplications());
    }
    _subscribeApplications();
  }

  void _subscribeApplications() {
    _appsSub?.cancel();
    _appsSub = null;

    if (!AppConfig.isFirebaseEnabled) {
      unawaited(_loadLocal());
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      unawaited(_loadLocal());
      return;
    }

    state = const AsyncValue.loading();
    _appsSub = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final jobs = snapshot.docs.map((doc) => _mapFirestoreDoc(doc, user.uid)).toList();
            state = AsyncValue.data(jobs);
          },
          onError: (Object e, StackTrace st) {
            state = AsyncValue.error(e, st);
          },
        );
  }

  AppliedJobModel _mapFirestoreDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String uid,
  ) {
    final map = doc.data();
    final appliedAt = map['appliedAt'];
    return AppliedJobModel.fromMap({
      'applicationId': doc.id,
      'jobId': map['jobId'],
      'userId': uid,
      'applicantName': map['applicantName'],
      'applicantEmail': map['applicantEmail'],
      'title': map['title'],
      'companyName': map['companyName'],
      'location': map['location'],
      'status': map['status'],
      'appliedAt': appliedAt is Timestamp
          ? appliedAt.toDate().toIso8601String()
          : DateTime.now().toIso8601String(),
    });
  }

  Future<void> _loadLocal() async {
    try {
      final jobs = await _loadItemsFromPrefs();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Returns `false` when Firebase is enabled but the user is not signed in.
  Future<bool> apply(JobModel job) async {
    if (AppConfig.isFirebaseEnabled && _auth.currentUser == null) {
      return false;
    }

    final current = state.value ?? await _currentItems();
    final alreadyApplied = current.any((item) => item.jobId == job.id);
    if (alreadyApplied) return true;

    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest';
    final email = user?.email ?? 'guest@example.com';
    final name = user?.displayName?.trim().isNotEmpty == true ? user!.displayName!.trim() : email;
    final latest = AppliedJobModel.fromJob(
      job,
      userId: uid,
      applicantName: name,
      applicantEmail: email,
    );
    final next = [latest, ...current];
    await _persist(next, latestApplication: latest);
    if (!AppConfig.isFirebaseEnabled || user == null) {
      state = AsyncValue.data(next);
    }
    return true;
  }

  Future<void> remove(String applicationId) async {
    final current = state.value ?? const <AppliedJobModel>[];
    final next = current.where((item) => item.applicationId != applicationId).toList();
    await _persist(next, deleteApplicationId: applicationId);
    if (!AppConfig.isFirebaseEnabled || _auth.currentUser == null) {
      state = AsyncValue.data(next);
    }
  }

  Future<void> clearAll() async {
    await _persist(const <AppliedJobModel>[], clearAll: true);
    if (!AppConfig.isFirebaseEnabled || _auth.currentUser == null) {
      state = const AsyncValue.data(<AppliedJobModel>[]);
    }
  }

  Future<List<AppliedJobModel>> _currentItems() async {
    if (AppConfig.isFirebaseEnabled && _auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => _mapFirestoreDoc(doc, uid)).toList();
    }
    return _loadItemsFromPrefs();
  }

  Future<List<AppliedJobModel>> _loadItemsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_appliedJobsStorageKey) ?? const <String>[];
    final jobs = raw
        .map((item) => AppliedJobModel.fromMap(jsonDecode(item) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    return jobs;
  }

  Future<void> _persist(
    List<AppliedJobModel> items, {
    AppliedJobModel? latestApplication,
    String? deleteApplicationId,
    bool clearAll = false,
  }) async {
    if (AppConfig.isFirebaseEnabled && _auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      final collection = _firestore.collection('users').doc(uid).collection('applications');
      if (clearAll) {
        final snapshot = await collection.get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        final globalSnapshot = await _firestore
            .collection('applications')
            .where('userId', isEqualTo: uid)
            .get();
        for (final doc in globalSnapshot.docs) {
          await doc.reference.delete();
        }
        return;
      }
      if (deleteApplicationId != null) {
        await collection.doc(deleteApplicationId).delete();
        await _firestore.collection('applications').doc(deleteApplicationId).delete();
        return;
      }
      if (latestApplication != null) {
        await collection.doc(latestApplication.applicationId).set({
          'jobId': latestApplication.jobId,
          'userId': latestApplication.userId,
          'applicantName': latestApplication.applicantName,
          'applicantEmail': latestApplication.applicantEmail,
          'title': latestApplication.title,
          'companyName': latestApplication.companyName,
          'location': latestApplication.location,
          'status': latestApplication.status,
          'appliedAt': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('applications').doc(latestApplication.applicationId).set({
          'applicationId': latestApplication.applicationId,
          'jobId': latestApplication.jobId,
          'userId': latestApplication.userId,
          'applicantName': latestApplication.applicantName,
          'applicantEmail': latestApplication.applicantEmail,
          'title': latestApplication.title,
          'companyName': latestApplication.companyName,
          'location': latestApplication.location,
          'status': latestApplication.status,
          'appliedAt': FieldValue.serverTimestamp(),
        });
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_appliedJobsStorageKey, encoded);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _appsSub?.cancel();
    super.dispose();
  }
}
