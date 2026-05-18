import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/config/app_config.dart';
import '../../recruiter/data/recruiter_jobs_repository.dart';
import '../domain/job_model.dart';
import 'job_api_service.dart';
import 'job_local_data_source.dart';

class JobsRepository {
  final JobLocalDataSource _local = JobLocalDataSource();
  final JobApiService _api = JobApiService();
  final RecruiterJobsRepository _recruiterJobs = RecruiterJobsRepository();

  Future<List<JobModel>> getJobs() async {
    final localJobs = await _local.loadSeedJobs();
    final recruiterJobs = await _loadRecruiterJobs();

    var merged = _mergeById([...recruiterJobs, ...localJobs]);

    if (!AppConfig.enableJobsApi) {
      return merged;
    }

    try {
      final apiJobs = await _api.fetchJobsFromApi();
      merged = _mergeById([...merged, ...apiJobs]);
      return merged;
    } catch (_) {
      return merged;
    }
  }

  Future<List<JobModel>> _loadRecruiterJobs() async {
    if (!AppConfig.isFirebaseEnabled) {
      return const <JobModel>[];
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .where((doc) => (doc.data()['status']?.toString() ?? 'open') == 'open')
        .map(_recruiterJobs.fromFirestoreDoc)
        .toList();
  }

  List<JobModel> _mergeById(List<JobModel> jobs) {
    final map = <String, JobModel>{};
    for (final job in jobs) {
      map[job.id] = job;
    }
    return map.values.toList();
  }
}
