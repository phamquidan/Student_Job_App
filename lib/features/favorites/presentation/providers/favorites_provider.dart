import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/app_config.dart';
import '../../../jobs/domain/job_model.dart';

const _favoritesStorageKey = 'favorite_jobs_v1';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<Set<String>>>(
  (ref) => FavoritesNotifier(),
);

class FavoritesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  FavoritesNotifier() : super(const AsyncValue.loading()) {
    if (AppConfig.useFirebase) {
      _authSub = _auth.authStateChanges().listen((_) => load());
    }
    load();
  }

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  Future<void> load() async {
    try {
      if (AppConfig.useFirebase && _auth.currentUser != null) {
        state = AsyncValue.data(await _loadFromFirestore(_auth.currentUser!.uid));
      } else {
        state = AsyncValue.data(await _loadFromLocal());
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggle(JobModel job) async {
    final current = {...(state.value ?? <String>{})};
    final wasFavorite = current.contains(job.id);
    if (wasFavorite) {
      current.remove(job.id);
    } else {
      current.add(job.id);
    }
    state = AsyncValue.data(current);

    if (AppConfig.useFirebase && _auth.currentUser != null) {
      final doc = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('favorites').doc(job.id);
      if (wasFavorite) {
        await doc.delete();
      } else {
        await doc.set({
          'jobId': job.id,
          'title': job.title,
          'companyName': job.companyName,
          'location': job.location,
          'savedAt': FieldValue.serverTimestamp(),
        });
      }
      return;
    }
    await _persistLocal(current);
  }

  Future<Set<String>> _loadFromFirestore(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).collection('favorites').get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<Set<String>> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favoritesStorageKey) ?? const <String>[];
    return raw.toSet();
  }

  Future<void> _persistLocal(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesStorageKey, ids.toList());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
