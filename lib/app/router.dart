import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/jobs/presentation/screens/home_screen.dart';
import '../features/jobs/presentation/screens/job_detail_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/applications/presentation/screens/applied_jobs_screen.dart';
import '../features/recruiter/presentation/screens/manage_posts_screen.dart';
import '../features/recruiter/presentation/screens/post_job_screen.dart';
import '../features/recruiter/presentation/screens/applicants_list_screen.dart';
import '../features/jobs/domain/job_model.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/job-detail',
      builder: (_, state) => JobDetailScreen(job: state.extra! as JobModel),
    ),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/applied-jobs', builder: (_, __) => const AppliedJobsScreen()),
    GoRoute(path: '/recruiter/manage-posts', builder: (_, __) => const ManagePostsScreen()),
    GoRoute(path: '/recruiter/post-job', builder: (_, __) => const PostJobScreen()),
    GoRoute(path: '/recruiter/applicants', builder: (_, __) => const ApplicantsListScreen()),
  ],
);
