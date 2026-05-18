import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/config/job_ui_labels.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/widgets/stitch_glass_app_bar.dart';
import '../../../jobs/domain/job_model.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';

class ManagePostsScreen extends ConsumerStatefulWidget {
  const ManagePostsScreen({super.key});

  @override
  ConsumerState<ManagePostsScreen> createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends ConsumerState<ManagePostsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final asyncJobs = ref.watch(jobsProvider);

    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StitchGlassBackBar(
            title: AppStrings.appName,
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.recruiterPostJob),
                icon: const Icon(Icons.add_circle_outline),
                color: StitchColors.primary,
              ),
            ],
          ),
          Expanded(
            child: asyncJobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (jobs) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                final recruiterJobs = AppConfig.isFirebaseEnabled
                    ? jobs
                        .where((j) => j.source == 'recruiter' && j.createdBy == uid)
                        .toList()
                    : jobs;
                final filtered = _filter == 'all'
                    ? recruiterJobs
                    : recruiterJobs.where((j) => j.jobType == _filter).toList();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào mừng trở lại,',
                            style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, height: 1.05),
                          ),
                          Text(
                            AppStrings.recruiterSectionTitle,
                            style: GoogleFonts.manrope(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: StitchColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Quản lý tin đăng và ứng viên.',
                            style: GoogleFonts.inter(fontSize: 16, color: StitchColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.post_add_rounded,
                                  value: '${recruiterJobs.length}',
                                  label: 'Tin đang có',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatTile(
                                  icon: Icons.groups_rounded,
                                  value: '—',
                                  label: 'Ứng viên',
                                  dark: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _MessagesStrip(),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tin đã đăng',
                                    style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'Chỉ hiển thị các tin bạn đã đăng.',
                                    style: GoogleFonts.inter(fontSize: 13, color: StitchColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _FilterChip(label: 'Tất cả', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                                const SizedBox(width: 8),
                                for (final option in JobUiLabels.recruiterTypeOptions) ...[
                                  _FilterChip(
                                    label: option.label,
                                    selected: _filter == option.id,
                                    onTap: () => setState(() => _filter = option.id),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    if (filtered.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('Không có tin phù hợp bộ lọc.')),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) => _RecruiterJobCard(
                          job: filtered[i],
                          onManage: () => context.push(AppRoutes.jobDetail, extra: filtered[i]),
                        ),
                      ),
                  ],
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.dark = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? StitchColors.primary : StitchColors.surfaceContainerLowest;
    final fg = dark ? StitchColors.onPrimary : StitchColors.onSurface;
    final sub = dark ? StitchColors.onPrimary.withValues(alpha: 0.7) : StitchColors.outline;

    return AspectRatio(
      aspectRatio: 1.1,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: dark ? StitchColors.onPrimary : StitchColors.primary, size: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, color: fg)),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1, color: sub),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: StitchColors.tertiaryContainer.withValues(alpha: 0.6),
            child: const Icon(Icons.mail_outline, color: StitchColors.tertiary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thông báo', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 16)),
                Text('Phản hồi ứng viên mới nhất', style: GoogleFonts.inter(fontSize: 13, color: StitchColors.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: StitchColors.outline),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StitchColors.primary : StitchColors.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: selected ? StitchColors.onPrimary : StitchColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecruiterJobCard extends StatelessWidget {
  const _RecruiterJobCard({required this.job, required this.onManage});

  final JobModel job;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: StitchColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.work_outline, color: StitchColors.primary.withValues(alpha: 0.85)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: StitchColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ĐANG MỞ',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: StitchColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(job.title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            '${job.category} • ${job.location}',
            style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: StitchColors.brandGradient,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: onManage,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'Chi tiết / Quản lý',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: StitchColors.onPrimary, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
