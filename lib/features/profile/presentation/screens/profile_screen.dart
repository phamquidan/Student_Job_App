import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _controllersInitialized = false;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _majorController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!AppConfig.isFirebaseEnabled) return;
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'displayName': _nameController.text.trim(),
        'school': _schoolController.text.trim(),
        'major': _majorController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Also update Auth profile display name
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.displayName != _nameController.text.trim()) {
        await firebaseUser.updateDisplayName(_nameController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
        );
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu hồ sơ thất bại: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

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

    final profileAsync = ref.watch(userProfileProvider);
    if (user?.uid != _lastUid) {
      _lastUid = user?.uid;
      _controllersInitialized = false;
    }

    if (profileAsync.hasValue && !_controllersInitialized) {
      final data = profileAsync.value!;
      _nameController.text = data['displayName']?.toString() ?? user?.displayName ?? '';
      _schoolController.text = data['school']?.toString() ?? '';
      _majorController.text = data['major']?.toString() ?? '';
      _phoneController.text = data['phone']?.toString() ?? '';
      _controllersInitialized = true;
    }

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
                  boxShadow: const [
                    BoxShadow(color: StitchColors.ambientShadow, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.person_rounded, size: 44, color: StitchColors.onSecondaryContainer),
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
                icon: _isEditing ? Icons.close_rounded : Icons.edit_outlined,
                label: _isEditing ? 'Hủy' : 'Chỉnh sửa hồ sơ',
                onTap: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _controllersInitialized = false;
                    }
                  });
                },
                isPrimary: !_isEditing,
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
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _schoolController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Trường',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _majorController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Chuyên ngành',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: StitchColors.ctaGradient,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _isSaving ? null : _saveProfile,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Lưu thay đổi',
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'Thông tin hồ sơ sẽ giúp nhà tuyển dụng đánh giá bạn nhanh hơn.',
                      style: GoogleFonts.inter(fontSize: 12, color: StitchColors.onSurfaceVariant),
                    ),
                  ],
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
        boxShadow: const [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: Offset(0, 6)),
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
