import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/config/job_ui_labels.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/job_model.dart';
import '../providers/jobs_provider.dart';
import '../widgets/stitch_job_cards.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(jobSearchProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showShortcuts(BuildContext context) {
    final isRecruiter = ref.read(isRecruiterProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: StitchColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: const Text('Việc đã ứng tuyển'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.appliedJobs);
                },
              ),
              if (isRecruiter) ...[
                ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: const Text('Quản lý bài đăng'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.recruiterManagePosts);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('Đăng tin tuyển dụng'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.recruiterPostJob);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Danh sách ứng viên'),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.recruiterApplicants);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSourceFilter(BuildContext context) {
    final current = ref.read(sourceFilterProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: StitchColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nguồn tin', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            for (final e in JobUiLabels.sourceOptions)
              RadioListTile<String>(
                value: e.id,
                groupValue: current,
                title: Text(e.label),
                onChanged: (v) {
                  if (v != null) {
                    ref.read(sourceFilterProvider.notifier).state = v;
                  }
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  List<JobModel> _rowJobs(List<JobModel> filtered) {
    if (!widget.compact && filtered.isNotEmpty) {
      return filtered.skip(1).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final asyncJobs = ref.watch(jobsProvider);
    final filteredJobs = ref.watch(filteredJobsProvider);
    final quickTag = ref.watch(quickTagProvider);
    final user = ref.watch(currentUserProvider);
    final topPad = MediaQuery.paddingOf(context).top;
    final rows = _rowJobs(filteredJobs);

    return ColoredBox(
      color: StitchColors.background,
      child: asyncJobs.when(
        data: (_) => RefreshIndicator(
          color: StitchColors.primary,
          onRefresh: () async => ref.invalidate(jobsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _GlassHeaderDelegate(
                  topPadding: topPad,
                  child: _HomeTopBar(
                    user: user,
                    onMenu: () => _showShortcuts(context),
                  ),
                ),
              ),
              if (!widget.compact)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                    child: Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
                        children: const [
                          TextSpan(text: 'Sắp xếp '),
                          TextSpan(
                            text: 'chương tiếp theo',
                            style: TextStyle(
                              color: StitchColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(text: ' của bạn.'),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                  child: _SearchAndChips(
                    controller: _searchController,
                    onSearchChanged: (v) => ref.read(jobSearchProvider.notifier).state = v,
                    quickTag: quickTag,
                    onQuickTag: (v) => ref.read(quickTagProvider.notifier).state = v,
                    onOpenSourceFilter: () => _showSourceFilter(context),
                  ),
                ),
              ),
              if (filteredJobs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(message: 'Không tìm thấy công việc phù hợp.'),
                )
              else ...[
                if (!widget.compact && filteredJobs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gợi ý cho bạn',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Xem tất cả'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!widget.compact && filteredJobs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _FeaturedWithFavorite(
                        job: filteredJobs.first,
                        onOpen: () => context.push(AppRoutes.jobDetail, extra: filteredJobs.first),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tin mới đăng',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: StitchColors.surfaceContainerLow,
                                foregroundColor: StitchColors.onSurfaceVariant,
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.chevron_left),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              style: IconButton.styleFrom(
                                backgroundColor: StitchColors.surfaceContainerLow,
                                foregroundColor: StitchColors.onSurfaceVariant,
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 120),
                  sliver: SliverList.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final job = rows[index];
                      return _JobRowWithFavorite(
                        job: job,
                        onOpen: () => context.push(AppRoutes.jobDetail, extra: job),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
      ),
    );
  }
}

class _FeaturedWithFavorite extends ConsumerWidget {
  const _FeaturedWithFavorite({required this.job, required this.onOpen});

  final JobModel job;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFav = favoriteIds.contains(job.id);

    return StitchFeaturedJobCard(
      job: job,
      isBookmarked: isFav,
      onBookmark: () => ref.read(favoritesProvider.notifier).toggle(job),
      onApply: onOpen,
    );
  }
}

class _JobRowWithFavorite extends ConsumerWidget {
  const _JobRowWithFavorite({required this.job, required this.onOpen});

  final JobModel job;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFav = favoriteIds.contains(job.id);

    return StitchJobRowCard(
      job: job,
      isBookmarked: isFav,
      onBookmark: () => ref.read(favoritesProvider.notifier).toggle(job),
      onDetails: onOpen,
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.user, required this.onMenu});

  final User? user;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final email = user?.email;
    final Widget avatarChild = (email != null && email.isNotEmpty)
        ? Text(
            email.substring(0, 1).toUpperCase(),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: StitchColors.onSecondaryContainer),
          )
        : Icon(Icons.person_outline, color: StitchColors.onSecondaryContainer.withValues(alpha: 0.9));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: StitchColors.secondaryContainer,
            child: avatarChild,
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: StitchColors.primaryDim,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onMenu,
            style: IconButton.styleFrom(backgroundColor: StitchColors.surfaceContainerLow.withValues(alpha: 0.5)),
            icon: const Icon(Icons.notifications_outlined),
            color: StitchColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _GlassHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GlassHeaderDelegate({required this.topPadding, required this.child});

  final double topPadding;
  final Widget child;

  static const double _barHeight = 56;

  @override
  double get minExtent => topPadding + _barHeight;

  @override
  double get maxExtent => topPadding + _barHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: StitchColors.glassBar,
            border: Border(
              bottom: BorderSide(color: StitchColors.surfaceContainer.withValues(alpha: 0.85)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: SizedBox(height: _barHeight, child: child),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _GlassHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding || oldDelegate.child != child;
  }
}

class _SearchAndChips extends StatelessWidget {
  const _SearchAndChips({
    required this.controller,
    required this.onSearchChanged,
    required this.quickTag,
    required this.onQuickTag,
    required this.onOpenSourceFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final String quickTag;
  final ValueChanged<String> onQuickTag;
  final VoidCallback onOpenSourceFilter;

  @override
  Widget build(BuildContext context) {
    final chips = JobUiLabels.quickTagOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm theo tên việc, công ty, từ khóa...',
            prefixIcon: const Icon(Icons.search, color: StitchColors.primary),
            filled: true,
            fillColor: StitchColors.surfaceContainerLowest,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: StitchColors.surfaceContainer, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: StitchColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Bộ lọc nhanh',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: StitchColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: StitchColors.surfaceContainerLowest,
                  foregroundColor: StitchColors.onSurfaceVariant,
                  side: const BorderSide(color: StitchColors.surfaceContainer, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onOpenSourceFilter,
                icon: const Icon(Icons.tune),
              ),
              const SizedBox(width: 10),
              for (final c in chips) ...[
                _FilterChipPill(
                  label: c.label,
                  selected: quickTag == c.id,
                  onTap: () => onQuickTag(c.id),
                ),
                const SizedBox(width: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StitchColors.primary : StitchColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? StitchColors.primary : StitchColors.surfaceContainer,
              width: 2,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? StitchColors.onPrimary : StitchColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
