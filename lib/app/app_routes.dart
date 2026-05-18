abstract final class AppRoutes {
  static const home = '/home';
  static const explore = '/explore';
  static const favorites = '/favorites';
  static const profile = '/profile';

  static const login = '/login';
  static const register = '/register';
  static const jobDetail = '/job-detail';
  static const appliedJobs = '/applied-jobs';
  static const uploadCv = '/upload-cv';

  static const recruiterManagePosts = '/recruiter/manage-posts';
  static const recruiterPostJob = '/recruiter/post-job';
  static const recruiterApplicants = '/recruiter/applicants';

  static const recruiterPaths = <String>{
    recruiterManagePosts,
    recruiterPostJob,
    recruiterApplicants,
  };

  static const authRequiredPaths = <String>{
    uploadCv,
    appliedJobs,
    ...recruiterPaths,
  };

  static bool isRecruiterPath(String path) => recruiterPaths.contains(path);

  static bool requiresAuth(String path) => authRequiredPaths.contains(path);
}
