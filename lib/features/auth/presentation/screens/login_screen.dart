import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../providers/auth_state_provider.dart';
import '../widgets/auth_ui.dart';
import '../../../applications/presentation/providers/applied_jobs_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _remember = true;
  bool _obscurePassword = true;
  bool _authNoticeShown = false;

  String _resolvePostLoginRoute(BuildContext context) {
    final redirect = GoRouterState.of(context).uri.queryParameters['redirect']?.trim();
    if (redirect != null && redirect.isNotEmpty && redirect.startsWith('/')) {
      return redirect;
    }
    return AppRoutes.home;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authNoticeShown) return;

    final reason = GoRouterState.of(context).uri.queryParameters['reason'];
    if (reason != 'auth_required') return;

    _authNoticeShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginRequired)),
      );
      final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
      if (redirect != null && redirect.isNotEmpty) {
        context.go('${AppRoutes.login}?redirect=${Uri.encodeComponent(redirect)}');
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.loginMissingFields)),
      );
      return;
    }

    if (!AppConfig.isFirebaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Firebase chưa sẵn sàng. Kiểm tra cấu hình Firebase rồi thử lại.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authServiceProvider).signIn(email: email, password: password);
      if (!mounted) return;

      final pendingJob = ref.read(pendingApplyJobProvider);
      if (pendingJob != null) {
        ref.read(pendingApplyJobProvider.notifier).state = null;
        final applied = await ref.read(appliedJobsProvider.notifier).apply(pendingJob);
        if (!mounted) return;
        if (applied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.applySuccess)),
          );
        }
      }

      context.go(_resolvePostLoginRoute(context));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.authLoginFailedPrefix} ${e.message ?? e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.authLoginUnknownErrorPrefix} $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (AppConfig.isFirebaseEnabled && user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(_resolvePostLoginRoute(context));
        }
      });
    }

    return AuthCardScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: StitchColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chào mừng trở lại',
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StitchColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Đăng nhập để tiếp tục hành trình nghề nghiệp của bạn.',
            style: GoogleFonts.inter(
              color: StitchColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          const AuthSectionLabel('EMAIL'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@school.edu.vn'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const AuthSectionLabel('MẬT KHẨU'),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Quên mật khẩu?',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: StitchColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Giữ đăng nhập 30 ngày',
                  style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AuthGradientButton(
            label: AppStrings.loginLabel,
            onTap: _submit,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push(AppRoutes.register),
            child: Text(
              'Chưa có tài khoản? Đăng ký',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: StitchColors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              AppStrings.backLabel,
              style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
