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

final appliedJobsProvider =
    StateNotifierProvider<AppliedJobsNotifier, AsyncValue<List<AppliedJobModel>>>(
      (ref) => AppliedJobsNotifier(),
    );

class AppliedJobsNotifier extends StateNotifier<AsyncValue<List<AppliedJobModel>>> {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  AppliedJobsNotifier() : super(const AsyncValue.loading()) {
    if (AppConfig.isFirebaseEnabled) {
      _authSub = _auth.authStateChanges().listen((_) => _load());
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final jobs = await _loadItems();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> apply(JobModel job) async {
    final current = state.value ?? await _loadItems();
    final alreadyApplied = current.any((item) => item.jobId == job.id);
    if (alreadyApplied) return;

    final next = [AppliedJobModel.fromJob(job), ...current];
    await _persist(next, latestJob: job);
    state = AsyncValue.data(next);
  }

  Future<void> remove(String applicationId) async {
    final current = state.value ?? const <AppliedJobModel>[];
    final next = current.where((item) => item.applicationId != applicationId).toList();
    await _persist(next, deleteApplicationId: applicationId);
    state = AsyncValue.data(next);
  }

  Future<void> clearAll() async {
    await _persist(const <AppliedJobModel>[], clearAll: true);
    state = const AsyncValue.data(<AppliedJobModel>[]);
  }

  Future<List<AppliedJobModel>> _loadItems() async {
    if (AppConfig.isFirebaseEnabled && _auth.currentUser != null) {
      final uid = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('applications')
          .orderBy('appliedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final map = doc.data();
        final appliedAt = map['appliedAt'];
        return AppliedJobModel.fromMap({
          'applicationId': doc.id,
          'jobId': map['jobId'],
          'title': map['title'],
          'companyName': map['companyName'],
          'location': map['location'],
          'appliedAt': appliedAt is Timestamp
              ? appliedAt.toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        });
      }).toList();
    }

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
    JobModel? latestJob,
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
        return;
      }
      if (deleteApplicationId != null) {
        await collection.doc(deleteApplicationId).delete();
        return;
      }
      if (latestJob != null) {
        await collection.doc(latestJob.id).set({
          'jobId': latestJob.id,
          'title': latestJob.title,
          'companyName': latestJob.companyName,
          'location': latestJob.location,
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
    super.dispose();
  }
}
