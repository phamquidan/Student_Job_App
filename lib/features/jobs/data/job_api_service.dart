import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../domain/job_model.dart';

class JobApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.jobsBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<JobModel>> fetchJobsFromApi() async {
    final response = await _dio.get(AppConfig.jobsPath);
    final data = response.data;

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(_mapApiJob).toList();
    }

    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(_mapApiJob)
          .toList();
    }

    return [];
  }

  JobModel _mapApiJob(Map<String, dynamic> item) {
    return JobModel(
      id: item['id']?.toString() ?? '',
      title: item['title']?.toString() ?? '',
      companyName: item['companyName']?.toString() ?? item['company']?.toString() ?? '',
      location: item['location']?.toString() ?? '',
      salaryText: item['salaryText']?.toString() ?? item['salary']?.toString() ?? 'Thoả thuận',
      jobType: item['jobType']?.toString() ?? 'full-time',
      category: item['category']?.toString() ?? 'General',
      description: item['description']?.toString() ?? '',
      requirements: item['requirements']?.toString() ?? '',
      benefits: item['benefits']?.toString() ?? '',
      source: 'api',
      applyType: item['applyType']?.toString() ?? 'webview',
      applyUrl: item['applyUrl']?.toString() ?? item['url']?.toString() ?? '',
    );
  }
}
