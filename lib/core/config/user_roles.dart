abstract final class UserRoles {
  static const student = 'student';
  static const recruiter = 'recruiter';

  static bool isRecruiter(String? role) => role == recruiter;
}
