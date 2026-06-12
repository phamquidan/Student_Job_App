import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/config/app_config.dart';
import '../../jobs/domain/job_model.dart';

class RecruiterJobsRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> createJob({
    required String title,
    required String companyName,
    required String location,
    required String salaryText,
    required String jobType,
    required String category,
    required String description,
  }) async {
    if (!AppConfig.isFirebaseEnabled) {
      throw StateError('Firebase chưa sẵn sàng.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để đăng tin.');
    }

    final doc = _firestore.collection('jobs').doc();
    await doc.set({
      'title': title.trim(),
      'companyName': companyName.trim(),
      'location': location.trim(),
      'salaryText': salaryText.trim(),
      'jobType': jobType,
      'category': category,
      'description': description.trim(),
      'requirements': 'Đang cập nhật',
      'benefits': 'Đang cập nhật',
      'source': 'recruiter',
      'applyType': 'internal',
      'applyUrl': '',
      'status': 'open',
      'createdBy': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Keep `id` in document for compatibility with existing mapper.
      'id': doc.id,
    });
  }

  Future<void> updateJob({
    required String jobId,
    required String title,
    required String companyName,
    required String location,
    required String salaryText,
    required String jobType,
    required String category,
    required String description,
  }) async {
    if (!AppConfig.isFirebaseEnabled) {
      throw StateError('Firebase chưa sẵn sàng.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để cập nhật tin.');
    }

    await _firestore.collection('jobs').doc(jobId).update({
      'title': title.trim(),
      'companyName': companyName.trim(),
      'location': location.trim(),
      'salaryText': salaryText.trim(),
      'jobType': jobType,
      'category': category,
      'description': description.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteJob(String jobId) async {
    if (!AppConfig.isFirebaseEnabled) {
      throw StateError('Firebase chưa sẵn sàng.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để xóa tin.');
    }

    await _firestore.collection('jobs').doc(jobId).delete();
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    if (!AppConfig.isFirebaseEnabled) {
      throw StateError('Firebase chưa sẵn sàng.');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để thay đổi trạng thái tin.');
    }

    await _firestore.collection('jobs').doc(jobId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  JobModel fromFirestoreDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final map = <String, dynamic>{
      'id': doc.id,
      'title': data['title'],
      'companyName': data['companyName'],
      'location': data['location'],
      'salaryText': data['salaryText'],
      'jobType': data['jobType'],
      'category': data['category'],
      'description': data['description'],
      'requirements': data['requirements'],
      'benefits': data['benefits'],
      'source': data['source'],
      'applyType': data['applyType'],
      'applyUrl': data['applyUrl'],
      'createdBy': data['createdBy'],
      'status': data['status'],
    };
    return JobModel.fromMap(map);
  }
}
