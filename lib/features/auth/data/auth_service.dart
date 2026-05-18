import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/user_roles.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this._auth);

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user;
    if (user != null) {
      await _ensureUserProfile(user);
    }
    return credential;
  }

  Future<void> _ensureUserProfile(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();
    final data = doc.data() ?? const <String, dynamic>{};
    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : data['displayName']?.toString() ?? user.email ?? 'Sinh viên';

    await ref.set({
      'displayName': displayName,
      'email': user.email ?? data['email'] ?? '',
      'role': data['role'] ?? UserRoles.student,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!doc.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
    String role = UserRoles.student,
  }) async {
    final normalizedRole = UserRoles.isRecruiter(role) ? UserRoles.recruiter : UserRoles.student;
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'displayName': displayName,
        'email': email,
        'role': normalizedRole,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return credential;
  }

  Future<void> signOut() => _auth.signOut();
}
