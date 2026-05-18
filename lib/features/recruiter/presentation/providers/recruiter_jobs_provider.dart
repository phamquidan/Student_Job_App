import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/recruiter_jobs_repository.dart';

final recruiterJobsRepositoryProvider = Provider<RecruiterJobsRepository>((ref) {
  return RecruiterJobsRepository();
});
