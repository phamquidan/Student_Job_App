import 'dart:ui';

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
                              boxShadow: [
                                BoxShadow(
                                  color: StitchColors.ambientShadow,
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
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
                          boxShadow: [
                            BoxShadow(color: StitchColors.ambientShadow, blurRadius: 24, offset: const Offset(0, 10)),
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
            onApply: () async {
              if (canApplyInternal) {
                if (AppConfig.isFirebaseEnabled && ref.read(currentUserProvider) == null) {
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
                final applied = await ref.read(appliedJobsProvider.notifier).apply(job);
                if (!context.mounted) return;
                if (!applied) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.applyLoginRequired)),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      wasApplied ? AppStrings.applyAlreadySubmitted : AppStrings.applySuccess,
                    ),
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
        boxShadow: [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: const Offset(0, 6)),
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
  _DetailHeaderDelegate({required this.topPadding, required this.onBack, required this.onShare});

  final double topPadding;
  final VoidCallback onBack;
  final VoidCallback onShare;

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
          decoration: BoxDecoration(color: StitchColors.glassBar),
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
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_outlined),
                    color: StitchColors.onSurfaceVariant,
                  ),
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
    return oldDelegate.topPadding != topPadding;
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.canApplyInternal,
    required this.isFavorite,
    required this.onApply,
    required this.onToggleFavorite,
  });

  final bool canApplyInternal;
  final bool isFavorite;
  final Future<void> Function() onApply;
  final VoidCallback onToggleFavorite;

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
                      gradient: StitchColors.ctaGradient,
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
                              canApplyInternal ? 'Ứng tuyển ngay' : 'Mở link ứng tuyển',
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
                    onTap: onToggleFavorite,
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: StitchColors.onSurfaceVariant,
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
