import '../../../core/config/app_config.dart';
import '../domain/job_model.dart';
import 'job_api_service.dart';
import 'job_local_data_source.dart';

class JobsRepository {
  final JobLocalDataSource _local = JobLocalDataSource();
  final JobApiService _api = JobApiService();

  Future<List<JobModel>> getJobs() async {
    final localJobs = await _local.loadSeedJobs();

    if (!AppConfig.enableJobsApi) {
      return localJobs;
    }

    try {
      final apiJobs = await _api.fetchJobsFromApi();
      return [...localJobs, ...apiJobs];
    } catch (_) {
      return localJobs;
    }
  }
}
