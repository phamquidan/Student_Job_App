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

/// Quick chips on home: `all` | `remote` | `internship` | `part-time` | `full-time`
final quickTagProvider = StateProvider<String>((ref) => 'all');

final filteredJobsProvider = Provider<List<JobModel>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final keyword = ref.watch(jobSearchProvider).trim().toLowerCase();
  final typeFilter = ref.watch(jobTypeFilterProvider);
  final sourceFilter = ref.watch(sourceFilterProvider);
  final quickTag = ref.watch(quickTagProvider);

  return asyncJobs.maybeWhen(
    data: (jobs) => jobs.where((job) {
      final matchKeyword = keyword.isEmpty ||
          job.title.toLowerCase().contains(keyword) ||
          job.companyName.toLowerCase().contains(keyword) ||
          job.location.toLowerCase().contains(keyword) ||
          job.category.toLowerCase().contains(keyword);

      bool matchQuick;
      if (quickTag == 'all') {
        matchQuick = true;
      } else if (quickTag == 'remote') {
        matchQuick = job.location.toLowerCase().contains('remote');
      } else {
        matchQuick = job.jobType == quickTag;
      }

      final matchType = typeFilter == 'all' || job.jobType == typeFilter;
      final matchSource = sourceFilter == 'all' || job.source == sourceFilter;

      return matchKeyword && matchQuick && matchType && matchSource;
    }).toList(),
    orElse: () => [],
  );
});
