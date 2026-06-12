import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../applications/presentation/providers/applied_jobs_provider.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/job_model.dart';
import '../../../recruiter/presentation/providers/recruiter_jobs_provider.dart';
import '../providers/jobs_provider.dart';

class JobDetailScreen extends ConsumerWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  Future<void> _openApplyUrl(BuildContext context) async {
    final url = Uri.tryParse(job.applyUrl);
    if (url == null) return;

    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.cannotOpenApplyUrl)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canApplyInternal = job.applyType == 'internal';
    final favoriteIds = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFavorite = favoriteIds.contains(job.id);
    final topPad = MediaQuery.paddingOf(context).top;

    final currentUser = ref.watch(currentUserProvider);
    final isRecruiter = ref.watch(isRecruiterProvider);
    final isMyJob = currentUser != null && isRecruiter && job.createdBy == currentUser.uid;

    return Scaffold(
      backgroundColor: StitchColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _DetailHeaderDelegate(
                  topPadding: topPad,
                  onBack: () => Navigator.of(context).pop(),
                  onShare: () {},
                  isMyJob: isMyJob,
                  jobStatus: job.status,
                  onEdit: () => context.push(AppRoutes.recruiterPostJob, extra: job),
                  onToggleStatus: () async {
                    try {
                      final newStatus = job.status == 'open' ? 'closed' : 'open';
                      await ref.read(recruiterJobsRepositoryProvider).updateJobStatus(job.id, newStatus);
                      ref.invalidate(jobsProvider);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(newStatus == 'closed' ? 'Đã đóng nhận hồ sơ.' : 'Đã mở lại nhận hồ sơ.')),
                      );
                      context.pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi: $e')),
                      );
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: const Text('Bạn có chắc chắn muốn xóa tin tuyển dụng này? Hành động này không thể hoàn tác.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ref.read(recruiterJobsRepositoryProvider).deleteJob(job.id);
                        ref.invalidate(jobsProvider);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa tin tuyển dụng.')),
                        );
                        context.pop();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Xóa thất bại: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: StitchColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(
                                  color: StitchColors.ambientShadow,
                                  blurRadius: 20,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(Icons.apartment_rounded, size: 36, color: StitchColors.primary.withValues(alpha: 0.9)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.companyName.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: StitchColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  job.title,
                                  style: GoogleFonts.manrope(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    height: 1.05,
                                    color: StitchColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _pill(Icons.location_on_outlined, job.location, StitchColors.secondaryContainer, StitchColors.onSecondaryContainer),
                          _pill(Icons.payments_outlined, job.salaryText, StitchColors.surfaceContainerHigh, StitchColors.onSurface),
                          _pill(Icons.schedule_outlined, job.jobType, StitchColors.tertiaryContainer.withValues(alpha: 0.25), StitchColors.tertiary),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: StitchColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: StitchColors.ambientShadow, blurRadius: 24, offset: Offset(0, 10)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ĐĂNG TẢI',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: StitchColors.onSurfaceVariant,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(job),
                                  icon: Icon(
                                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                                    color: StitchColors.primaryDim,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _metaRow('Loại hình', job.jobType),
                            _metaRow('Danh mục', job.category),
                            _metaRow('Nguồn', job.source),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _sectionCard(
                        title: 'Mô tả công việc',
                        child: Text(
                          job.description,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            height: 1.65,
                            color: StitchColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionCard(
                        title: 'Yêu cầu',
                        child: _bulletText(job.requirements),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: StitchColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quyền lợi',
                              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            _bulletText(job.benefits),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _BottomActionBar(
            canApplyInternal: canApplyInternal,
            isFavorite: isFavorite,
            isMyJob: isMyJob,
            onEdit: () => context.push(AppRoutes.recruiterPostJob, extra: job),
            onApply: () async {
              if (isMyJob) {
                context.push(AppRoutes.recruiterApplicants, extra: job.id);
                return;
              }
              if (canApplyInternal) {
                final user = ref.read(currentUserProvider);
                if (AppConfig.isFirebaseEnabled && user == null) {
                  ref.read(pendingApplyJobProvider.notifier).state = job;
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.applyLoginRequired)),
                  );
                  context.push('${AppRoutes.login}?redirect=${Uri.encodeComponent(AppRoutes.appliedJobs)}');
                  return;
                }

                final wasApplied = ref.read(appliedJobsProvider).maybeWhen(
                      data: (items) => items.any((item) => item.jobId == job.id),
                      orElse: () => false,
                    );
                if (wasApplied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.applyAlreadySubmitted)),
                  );
                  return;
                }

                // Check user's CVs in Firestore
                List<Map<String, dynamic>> userCvs = [];
                if (AppConfig.isFirebaseEnabled && user != null) {
                  // Show loading dialog
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  
                  try {
                    final snapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('cvs')
                        .orderBy('uploadedAt', descending: true)
                        .get();
                    
                    userCvs = snapshot.docs.map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    }).toList();
                  } catch (e) {
                    // Ignore
                  } finally {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                    }
                  }
                  
                  if (userCvs.isEmpty) {
                    if (!context.mounted) return;
                    final uploadNow = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Chưa có tài liệu CV'),
                        content: const Text('Bạn chưa tải lên CV nào trong hồ sơ cá nhân. Vui lòng tải lên CV trước khi ứng tuyển.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Tải lên ngay'),
                          ),
                        ],
                      ),
                    );
                    if (uploadNow == true && context.mounted) {
                      context.push(AppRoutes.uploadCv);
                    }
                    return;
                  }
                }

                // If userCvs is not empty, show bottom sheet to select CV
                Map<String, dynamic>? selectedCv;
                if (userCvs.isNotEmpty) {
                  if (!context.mounted) return;
                  selectedCv = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    backgroundColor: StitchColors.surfaceContainerLowest,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (ctx) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                              child: Text(
                                'Chọn CV để ứng tuyển',
                                style: GoogleFonts.manrope(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: userCvs.length,
                                itemBuilder: (ctx, index) {
                                  final cv = userCvs[index];
                                  final name = cv['name']?.toString() ?? 'CV';
                                  final isPrimary = cv['isPrimary'] == true;
                                  return ListTile(
                                    leading: Icon(
                                      Icons.description_outlined,
                                      color: isPrimary ? StitchColors.primary : StitchColors.onSurfaceVariant,
                                    ),
                                    title: Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    trailing: isPrimary
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: StitchColors.secondaryContainer,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              'CHÍNH',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: StitchColors.onSecondaryContainer,
                                              ),
                                            ),
                                          )
                                        : null,
                                    onTap: () {
                                      Navigator.pop(ctx, cv);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                  );
                  if (selectedCv == null) return; // User cancelled CV selection
                }

                if (!context.mounted) return;
                final applied = await ref.read(appliedJobsProvider.notifier).apply(job, selectedCv: selectedCv);
                if (!context.mounted) return;
                if (!applied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.applyLoginRequired)),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.applySuccess),
                  ),
                );
              } else {
                await _openApplyUrl(context);
              }
            },
            onToggleFavorite: () => ref.read(favoritesProvider.notifier).toggle(job),
          ),
        ],
      ),
    );
  }

  static Widget _pill(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg),
          ),
        ],
      ),
    );
  }

  static Widget _metaRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant)),
          Flexible(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: StitchColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  static Widget _bulletText(String raw) {
    final lines = raw.split(RegExp(r'[\n•\-]+')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (lines.isEmpty) {
      return Text(raw, style: GoogleFonts.inter(fontSize: 15, height: 1.6, color: StitchColors.onSurfaceVariant));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: StitchColors.primary, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line,
                    style: GoogleFonts.inter(fontSize: 15, height: 1.55, color: StitchColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DetailHeaderDelegate({
    required this.topPadding,
    required this.onBack,
    required this.onShare,
    this.isMyJob = false,
    this.jobStatus = 'open',
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final bool isMyJob;
  final String jobStatus;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  static const double _h = 52;

  @override
  double get minExtent => topPadding + _h;

  @override
  double get maxExtent => topPadding + _h;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: StitchColors.glassBar),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, left: 8, right: 12),
            child: SizedBox(
              height: _h,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: StitchColors.onSurfaceVariant,
                  ),
                  Text(
                    AppStrings.appName,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: StitchColors.primaryDim,
                    ),
                  ),
                  const Spacer(),
                  if (isMyJob) ...[
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: StitchColors.onSurfaceVariant),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit?.call();
                        } else if (value == 'status') {
                          onToggleStatus?.call();
                        } else if (value == 'delete') {
                          onDelete?.call();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa tin'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(jobStatus == 'open' ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text(jobStatus == 'open' ? 'Đóng tuyển dụng' : 'Mở lại tuyển dụng'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Xóa tin đăng', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                      color: StitchColors.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DetailHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.isMyJob != isMyJob ||
        oldDelegate.jobStatus != jobStatus;
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.canApplyInternal,
    required this.isFavorite,
    required this.onApply,
    required this.onToggleFavorite,
    this.isMyJob = false,
    this.onEdit,
  });

  final bool canApplyInternal;
  final bool isFavorite;
  final Future<void> Function() onApply;
  final VoidCallback onToggleFavorite;
  final bool isMyJob;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.paddingOf(context).bottom + 14),
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainerLowest.withValues(alpha: 0.88),
              border: Border(top: BorderSide(color: StitchColors.outlineVariant.withValues(alpha: 0.2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: isMyJob ? StitchColors.brandGradient : StitchColors.ctaGradient,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: onApply,
                        child: Padding(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              isMyJob
                                  ? 'Quản lý ứng viên'
                                  : (canApplyInternal ? 'Ứng tuyển ngay' : 'Mở link ứng tuyển'),
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: StitchColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: isMyJob ? onEdit : onToggleFavorite,
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        isMyJob
                            ? Icons.edit_note_rounded
                            : (isFavorite ? Icons.bookmark : Icons.bookmark_border),
                        color: isMyJob ? StitchColors.primary : StitchColors.onSurfaceVariant,
                      ),
                    ),
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
