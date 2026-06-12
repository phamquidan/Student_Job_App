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
final locationFilterProvider = StateProvider<String>((ref) => 'all');
final salaryFilterProvider = StateProvider<String>((ref) => 'all');

/// Quick chips on home: `all` | `remote` | `internship` | `part-time` | `full-time`
final quickTagProvider = StateProvider<String>((ref) => 'all');

bool _matchLocation(String location, String filter) {
  if (filter == 'all') return true;
  final cleaned = location.trim().toLowerCase();
  if (filter == 'TP.HCM') {
    return cleaned.contains('hồ chí minh') || cleaned.contains('hcm') || cleaned.contains('tphcm');
  } else if (filter == 'Hà Nội') {
    return cleaned.contains('hà nội') || cleaned.contains('hn');
  } else if (filter == 'Đà Nẵng') {
    return cleaned.contains('đà nẵng') || cleaned.contains('dn');
  } else if (filter == 'Khác') {
    final isMainCity = cleaned.contains('hồ chí minh') || cleaned.contains('hcm') || cleaned.contains('tphcm') ||
                       cleaned.contains('hà nội') || cleaned.contains('hn') ||
                       cleaned.contains('đà nẵng') || cleaned.contains('dn');
    return !isMainCity;
  }
  return true;
}

bool _matchSalary(String salaryText, String filter) {
  if (filter == 'all') return true;
  final cleaned = salaryText.trim().toLowerCase();
  
  if (filter == 'negotiable') {
    return cleaned.contains('thỏa thuận') || cleaned.contains('thương lượng') || cleaned.isEmpty;
  }
  
  double? val;
  if (cleaned.contains('triệu')) {
    final matches = RegExp(r'([0-9.,]+)').firstMatch(cleaned);
    if (matches != null) {
      val = double.tryParse(matches.group(1)!.replaceAll(',', '.'));
    }
  } else if (cleaned.contains('k') || cleaned.contains('đ')) {
    final cleanNum = cleaned.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = double.tryParse(cleanNum);
    if (parsed != null) {
      if (parsed >= 100000) {
        val = parsed / 1000000;
      } else {
        val = parsed / 1000;
      }
    }
  }

  if (val == null) {
    if (cleaned.contains('thỏa thuận') || cleaned.contains('thương lượng')) {
      return false;
    }
    return true;
  }

  if (filter == 'under_5m') {
    return val < 5.0;
  } else if (filter == 'above_5m') {
    return val >= 5.0;
  }

  return true;
}

final filteredJobsProvider = Provider<List<JobModel>>((ref) {
  final asyncJobs = ref.watch(jobsProvider);
  final keyword = ref.watch(jobSearchProvider).trim().toLowerCase();
  final typeFilter = ref.watch(jobTypeFilterProvider);
  final sourceFilter = ref.watch(sourceFilterProvider);
  final locationFilter = ref.watch(locationFilterProvider);
  final salaryFilter = ref.watch(salaryFilterProvider);
  final quickTag = ref.watch(quickTagProvider);

  return asyncJobs.maybeWhen(
    data: (jobs) => jobs.where((job) {
      if (job.status == 'closed') return false;

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
      final matchLoc = _matchLocation(job.location, locationFilter);
      final matchSal = _matchSalary(job.salaryText, salaryFilter);

      return matchKeyword && matchQuick && matchType && matchSource && matchLoc && matchSal;
    }).toList(),
    orElse: () => [],
  );
});
