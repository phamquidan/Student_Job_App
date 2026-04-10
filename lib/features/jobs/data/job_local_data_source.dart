import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/job_model.dart';

class JobLocalDataSource {
  Future<List<JobModel>> loadSeedJobs() async {
    final jsonString = await rootBundle.loadString('assets/data/jobs_seed.json');
    final raw = jsonDecode(jsonString) as List<dynamic>;
    return raw
        .map((item) => JobModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
