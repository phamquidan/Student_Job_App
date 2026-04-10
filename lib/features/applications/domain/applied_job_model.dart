import 'package:flutter/foundation.dart';

import '../../jobs/domain/job_model.dart';

@immutable
class AppliedJobModel {
  final String applicationId;
  final String jobId;
  final String title;
  final String companyName;
  final String location;
  final DateTime appliedAt;

  const AppliedJobModel({
    required this.applicationId,
    required this.jobId,
    required this.title,
    required this.companyName,
    required this.location,
    required this.appliedAt,
  });

  factory AppliedJobModel.fromJob(JobModel job) {
    final now = DateTime.now();
    return AppliedJobModel(
      applicationId: '${job.id}-${now.millisecondsSinceEpoch}',
      jobId: job.id,
      title: job.title,
      companyName: job.companyName,
      location: job.location,
      appliedAt: now,
    );
  }

  factory AppliedJobModel.fromMap(Map<String, dynamic> map) {
    return AppliedJobModel(
      applicationId: map['applicationId']?.toString() ?? '',
      jobId: map['jobId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      appliedAt: DateTime.tryParse(map['appliedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'title': title,
      'companyName': companyName,
      'location': location,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }
}
