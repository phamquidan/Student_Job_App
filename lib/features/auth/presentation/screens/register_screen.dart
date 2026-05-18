import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/config/user_roles.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../providers/auth_state_provider.dart';
import '../widgets/auth_ui.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  String _role = UserRoles.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerInvalidFields)),
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
      await ref.read(authServiceProvider).register(
            email: email,
            password: password,
            displayName: name,
            role: _role,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.registerSuccess)),
      );
      context.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.authRegisterFailedPrefix} ${e.message ?? e.code}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.authRegisterUnknownErrorPrefix} $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Tạo tài khoản',
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StitchColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _role == UserRoles.recruiter
                ? 'Tạo tài khoản nhà tuyển dụng để đăng tin và quản lý ứng viên.'
                : 'Tạo tài khoản để bắt đầu tìm việc và xây dựng hồ sơ chuyên nghiệp.',
            style: GoogleFonts.inter(
              color: StitchColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            AppStrings.rolePickerLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: StitchColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _RoleChip(
                  label: AppStrings.roleStudentLabel,
                  icon: Icons.school_outlined,
                  selected: _role == UserRoles.student,
                  onTap: () => setState(() => _role = UserRoles.student),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RoleChip(
                  label: AppStrings.roleRecruiterLabel,
                  icon: Icons.business_center_outlined,
                  selected: _role == UserRoles.recruiter,
                  onTap: () => setState(() => _role = UserRoles.recruiter),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Họ và tên'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@school.edu.vn',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu (tối thiểu 6 ký tự)',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          AuthGradientButton(
            label: AppStrings.registerLabel,
            onTap: _submit,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.push(AppRoutes.login),
            child: Text(
              'Đã có tài khoản? Đăng nhập',
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

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StitchColors.secondaryContainer : StitchColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? StitchColors.onSecondaryContainer : StitchColors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? StitchColors.onSecondaryContainer : StitchColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
