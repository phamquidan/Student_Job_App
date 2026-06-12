import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/application_status_ui.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/widgets/stitch_glass_app_bar.dart';
import '../providers/applied_jobs_provider.dart';

class AppliedJobsScreen extends ConsumerStatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  ConsumerState<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends ConsumerState<AppliedJobsScreen> {
  String _segment = 'applied';

  @override
  Widget build(BuildContext context) {
    final appliedJobs = ref.watch(appliedJobsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StitchGlassBackBar(
            title: 'Hoạt động của tôi',
            actions: [
              IconButton(
                tooltip: 'Xóa toàn bộ',
                onPressed: () => ref.read(appliedJobsProvider.notifier).clearAll(),
                icon: const Icon(Icons.delete_sweep_outlined),
                color: StitchColors.onSurfaceVariant,
              ),
            ],
          ),
          Expanded(
            child: appliedJobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Không tải được lịch sử: $error')),
              data: (items) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'THEO DÕI TIẾN ĐỘ',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: StitchColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhật ký nghề\nnghiệp của bạn',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: StitchColors.onSurface,
                            ),
                          ),
                          Text(
                            'Theo dõi các đơn ứng tuyển và việc đã lưu.',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: StitchColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'applied', label: Text('Đã ứng tuyển'), icon: Icon(Icons.send_outlined)),
                              ButtonSegment(value: 'saved', label: Text('Đã lưu'), icon: Icon(Icons.bookmark_outline)),
                            ],
                            selected: {_segment},
                            onSelectionChanged: (s) {
                              if (s.isEmpty) return;
                              setState(() => _segment = s.first);
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_segment == 'applied' && items.isNotEmpty)
                            _ActivityPulseCard(total: items.length),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    if (_segment == 'saved')
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _SavedPlaceholder(onOpenFavorites: () => context.push(AppRoutes.favorites)),
                      )
                    else if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Bạn chưa ứng tuyển công việc nào. Hãy chọn một việc trên trang chủ và bấm ứng tuyển trong app.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, height: 1.5),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _AppliedActivityCard(
                            title: item.title,
                            subtitle: '${item.companyName} • ${item.location}',
                            status: item.status,
                            dateLabel: 'Ứng tuyển ${dateFormat.format(item.appliedAt)}',
                            feedback: item.feedback,
                            onRemove: () => ref.read(appliedJobsProvider.notifier).remove(item.applicationId),
                          );
                        },
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

class _ActivityPulseCard extends StatelessWidget {
  const _ActivityPulseCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: StitchColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: StitchColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TỔNG ĐƠN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: StitchColors.primaryContainer,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '$total',
                    style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Cập nhật theo lịch sử trong app',
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (total.clamp(0, 10)) / 10,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceholder extends StatelessWidget {
  const _SavedPlaceholder({required this.onOpenFavorites});

  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.bookmark_border, size: 56, color: StitchColors.outline.withValues(alpha: 0.7)),
        const SizedBox(height: 16),
        Text(
          'Việc đã lưu nằm trong tab Đã lưu trên thanh điều hướng.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 20),
        DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: StitchColors.brandGradient),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onOpenFavorites,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                child: Text(
                  'Mở việc đã lưu',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: StitchColors.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppliedActivityCard extends StatelessWidget {
  const _AppliedActivityCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.dateLabel,
    required this.onRemove,
    this.feedback = '',
  });

  final String title;
  final String subtitle;
  final String status;
  final String dateLabel;
  final VoidCallback onRemove;
  final String feedback;

  @override
  Widget build(BuildContext context) {
    final statusStyle = ApplicationStatusUi.forStatus(status);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: StitchColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.apartment_rounded, color: StitchColors.primary.withValues(alpha: 0.9)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: StitchColors.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusStyle.label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: statusStyle.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: StitchColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dateLabel.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: StitchColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (feedback.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: StitchColors.tertiaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: StitchColors.tertiaryContainer.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: StitchColors.tertiary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'PHẢN HỒI TỪ NHÀ TUYỂN DỤNG',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: StitchColors.tertiary,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    feedback,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.4,
                      color: StitchColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Xóa khỏi lịch sử'),
                style: TextButton.styleFrom(foregroundColor: StitchColors.tertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
