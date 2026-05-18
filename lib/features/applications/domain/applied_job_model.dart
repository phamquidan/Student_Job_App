import 'package:flutter/foundation.dart';

import '../../jobs/domain/job_model.dart';

@immutable
class AppliedJobModel {
  final String applicationId;
  final String jobId;
  final String userId;
  final String applicantName;
  final String applicantEmail;
  final String title;
  final String companyName;
  final String location;
  final String status;
  final DateTime appliedAt;

  const AppliedJobModel({
    required this.applicationId,
    required this.jobId,
    required this.userId,
    required this.applicantName,
    required this.applicantEmail,
    required this.title,
    required this.companyName,
    required this.location,
    required this.status,
    required this.appliedAt,
  });

  factory AppliedJobModel.fromJob(
    JobModel job, {
    required String userId,
    required String applicantName,
    required String applicantEmail,
  }) {
    final now = DateTime.now();
    return AppliedJobModel(
      applicationId: '${job.id}-${now.millisecondsSinceEpoch}',
      jobId: job.id,
      userId: userId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      title: job.title,
      companyName: job.companyName,
      location: job.location,
      status: 'submitted',
      appliedAt: now,
    );
  }

  factory AppliedJobModel.fromMap(Map<String, dynamic> map) {
    return AppliedJobModel(
      applicationId: map['applicationId']?.toString() ?? '',
      jobId: map['jobId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      applicantName: map['applicantName']?.toString() ?? '',
      applicantEmail: map['applicantEmail']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      companyName: map['companyName']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      status: map['status']?.toString() ?? 'submitted',
      appliedAt: DateTime.tryParse(map['appliedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'jobId': jobId,
      'userId': userId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'title': title,
      'companyName': companyName,
      'location': location,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }
}
