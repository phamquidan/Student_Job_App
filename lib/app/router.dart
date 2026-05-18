import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../core/config/app_config.dart';
import '../core/config/user_roles.dart';
import '../core/widgets/stitch_main_shell.dart';
import '../features/applications/presentation/screens/applied_jobs_screen.dart';
import '../features/auth/presentation/providers/auth_state_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/jobs/domain/job_model.dart';
import '../features/jobs/presentation/screens/home_screen.dart';
import '../features/jobs/presentation/screens/job_detail_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/upload_cv_screen.dart';
import '../features/recruiter/presentation/screens/applicants_list_screen.dart';
import '../features/recruiter/presentation/screens/manage_posts_screen.dart';
import '../features/recruiter/presentation/screens/post_job_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(authStateProvider, (_, __) => refresh.refresh());
  ref.listen(userRoleProvider, (_, __) => refresh.refresh());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final path = state.uri.path;
      if (!AppConfig.isFirebaseEnabled || !AppRoutes.requiresAuth(path)) {
        return null;
      }

      final auth = ref.read(authStateProvider);
      if (auth.isLoading) return null;

      final user = auth.valueOrNull;
      if (user == null) {
        final redirect = Uri.encodeComponent(path);
        return '${AppRoutes.login}?reason=auth_required&redirect=$redirect';
      }

      if (!AppRoutes.isRecruiterPath(path)) {
        return null;
      }

      final roleAsync = ref.read(userRoleProvider);
      if (roleAsync.isLoading) return null;

      final isRecruiter = UserRoles.isRecruiter(roleAsync.valueOrNull);
      if (!isRecruiter) {
        return '${AppRoutes.profile}?access=recruiter_denied';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StitchMainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, __) => const HomeScreen(compact: false),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                builder: (_, __) => const HomeScreen(compact: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorites,
                builder: (_, __) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => JobDetailScreen(job: state.extra! as JobModel),
      ),
      GoRoute(
        path: AppRoutes.appliedJobs,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const AppliedJobsScreen(),
      ),
      GoRoute(
        path: AppRoutes.uploadCv,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const UploadCvScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterManagePosts,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const ManagePostsScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterPostJob,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const PostJobScreen(),
      ),
      GoRoute(
        path: AppRoutes.recruiterApplicants,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, __) => const ApplicantsListScreen(),
      ),
    ],
  );
});
