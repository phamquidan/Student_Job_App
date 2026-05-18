import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/user_roles.dart';
import '../../data/auth_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  if (!AppConfig.isFirebaseEnabled) {
    return Stream<User?>.value(null);
  }
  return ref.watch(authServiceProvider).authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final userRoleProvider = StreamProvider<String>((ref) {
  if (!AppConfig.isFirebaseEnabled) {
    return Stream.value(UserRoles.student);
  }

  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value(UserRoles.student);
  }

  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map(
        (snapshot) => snapshot.data()?['role']?.toString() ?? UserRoles.student,
      );
});

final isRecruiterProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider).value;
  return UserRoles.isRecruiter(role);
});
