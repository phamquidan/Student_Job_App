import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../../../jobs/presentation/widgets/stitch_job_cards.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final jobsAsync = ref.watch(jobsProvider);
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: StitchColors.background,
      child: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không tải được danh sách đã lưu: $error')),
        data: (favoriteIds) {
          return jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Không tải được danh sách việc làm: $error')),
            data: (jobs) {
              final filtered = jobs.where((job) => favoriteIds.contains(job.id)).toList();
              if (filtered.isEmpty) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(24, top + 24, 24, 24),
                  child: Center(
                    child: Text(
                      'Bạn chưa lưu công việc nào. Hãy bấm biểu tượng bookmark ở trang chủ hoặc chi tiết việc làm.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, height: 1.5),
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(22, top + 16, 22, 120),
                itemCount: filtered.length + 1,
                separatorBuilder: (_, i) => i == 0 ? const SizedBox(height: 18) : const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Text(
                      'Đã lưu',
                      style: GoogleFonts.manrope(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: StitchColors.onSurface,
                      ),
                    );
                  }
                  final job = filtered[index - 1];
                  final isFav = favoriteIds.contains(job.id);
                  return StitchJobRowCard(
                    job: job,
                    isBookmarked: isFav,
                    onBookmark: () => ref.read(favoritesProvider.notifier).toggle(job),
                    onDetails: () => context.push(AppRoutes.jobDetail, extra: job),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
