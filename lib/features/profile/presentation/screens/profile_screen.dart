import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/config/user_roles.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _accessNoticeShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_accessNoticeShown) return;

    final access = GoRouterState.of(context).uri.queryParameters['access'];
    if (access != 'recruiter_denied') return;

    _accessNoticeShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.recruiterAccessDenied)),
      );
      context.go(AppRoutes.profile);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isRecruiter = ref.watch(isRecruiterProvider);
    final role = ref.watch(userRoleProvider).value ?? UserRoles.student;
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: StitchColors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(22, top + 16, 22, 120),
        children: [
          Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: StitchColors.secondaryContainer.withValues(alpha: 0.45),
                  boxShadow: [
                    BoxShadow(color: StitchColors.ambientShadow, blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Icon(Icons.person_rounded, size: 44, color: StitchColors.onSecondaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Sinh viên',
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: StitchColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'Chưa đăng nhập',
                      style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                    ),
                    if (AppConfig.isFirebaseEnabled && user != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRecruiter
                              ? StitchColors.primaryContainer
                              : StitchColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          UserRoles.isRecruiter(role)
                              ? AppStrings.roleRecruiterLabel
                              : AppStrings.roleStudentLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isRecruiter
                                ? StitchColors.primaryDim
                                : StitchColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _profileActionButton(
                icon: Icons.edit_outlined,
                label: 'Chỉnh sửa hồ sơ',
                onTap: () {},
                isPrimary: true,
              ),
              _profileActionButton(
                icon: Icons.cloud_upload_outlined,
                label: AppStrings.cvHubTitle,
                onTap: () => context.push(AppRoutes.uploadCv),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (!AppConfig.isFirebaseEnabled || user == null) ...[
            _section(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.login_rounded, color: StitchColors.primary),
                    title: Text(AppStrings.loginLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                    onTap: () => context.push(AppRoutes.login),
                  ),
                  ListTile(
                    leading: const Icon(Icons.app_registration_rounded, color: StitchColors.primary),
                    title: Text(AppStrings.registerLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                    onTap: () => context.push(AppRoutes.register),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (AppConfig.isFirebaseEnabled && user != null)
            _section(
              child: ListTile(
                leading: const Icon(Icons.logout_rounded, color: StitchColors.tertiary),
                title: Text('Đăng xuất', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.logoutSuccess)),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          if (isRecruiter)
            _section(
              title: AppStrings.recruiterSectionTitle,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.work_outline_rounded),
                    title: const Text('Quản lý bài đăng'),
                    onTap: () => context.push(AppRoutes.recruiterManagePosts),
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text('Đăng tin'),
                    onTap: () => context.push(AppRoutes.recruiterPostJob),
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: const Text('Danh sách ứng viên'),
                    onTap: () => context.push(AppRoutes.recruiterApplicants),
                  ),
                ],
              ),
            ),
          if (isRecruiter) const SizedBox(height: 16),
          _section(
            title: 'CV',
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: StitchColors.primary),
                  title: Text(AppStrings.cvHubTitle, style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  subtitle: Text('Tải lên & quản lý PDF/DOCX', style: GoogleFonts.inter(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.uploadCv),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: StitchColors.secondary),
                  title: Text('Trạng thái hồ sơ', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                  subtitle: Text('Hoàn thiện thông tin để tăng tỉ lệ phản hồi', style: GoogleFonts.inter(fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: AppStrings.profileSectionTitle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: user?.displayName,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(decoration: InputDecoration(labelText: 'Trường')),
                  const SizedBox(height: 12),
                  const TextField(decoration: InputDecoration(labelText: 'Chuyên ngành')),
                  const SizedBox(height: 12),
                  const TextField(decoration: InputDecoration(labelText: 'Số điện thoại')),
                  const SizedBox(height: 8),
                  Text(
                    'Thông tin hồ sơ sẽ giúp nhà tuyển dụng đánh giá bạn nhanh hơn.',
                    style: GoogleFonts.inter(fontSize: 12, color: StitchColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _section({String? title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Text(
                title,
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          child,
        ],
      ),
    );
  }

  static Widget _profileActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: isPrimary ? StitchColors.ctaGradient : null,
      color: isPrimary ? null : StitchColors.surfaceContainerLowest,
      border: isPrimary ? null : Border.all(color: StitchColors.outlineVariant.withValues(alpha: 0.4)),
    );

    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? Colors.white : StitchColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: isPrimary ? Colors.white : StitchColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
