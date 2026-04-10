import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/jobs_repository.dart';
import '../../domain/job_model.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepository();
});

final jobsProvider = FutureProvider<List<JobModel>>((ref) async {
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.getJobs();
});

final jobSearchProvider = StateProvider<String>((ref) => '');
final jobTypeFilterProvider = StateProvider<String>((ref) => 'all');
final sourceFilterProvider = StateProvider<String>((ref) => 'all');

final filteredJobsProvider = Provider<List<JobModel>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final keyword = ref.watch(jobSearchProvider).trim().toLowerCase();
  final typeFilter = ref.watch(jobTypeFilterProvider);
  final sourceFilter = ref.watch(sourceFilterProvider);

  return asyncJobs.maybeWhen(
    data: (jobs) => jobs.where((job) {
      final matchKeyword = keyword.isEmpty ||
          job.title.toLowerCase().contains(keyword) ||
          job.companyName.toLowerCase().contains(keyword) ||
          job.location.toLowerCase().contains(keyword) ||
          job.category.toLowerCase().contains(keyword);

      final matchType = typeFilter == 'all' || job.jobType == typeFilter;
      final matchSource = sourceFilter == 'all' || job.source == sourceFilter;

      return matchKeyword && matchType && matchSource;
    }).toList(),
    orElse: () => [],
  );
});
