import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../applications/presentation/providers/applied_jobs_provider.dart';
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
        const SnackBar(content: Text('Không mở được link ứng tuyển.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canApplyInternal = job.applyType == 'internal';
    final favoriteIds = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFavorite = favoriteIds.contains(job.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết việc làm'),
        actions: [
          IconButton(
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(job),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: isFavorite ? 'Bỏ lưu' : 'Lưu việc',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(job.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(job.companyName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${job.location} • ${job.salaryText}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(job.jobType)),
              Chip(label: Text(job.category)),
              Chip(label: Text('Nguồn: ${job.source}')),
              Chip(label: Text('Apply: ${job.applyType}')),
            ],
          ),
          const SizedBox(height: 18),
          Text('Mô tả', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(job.description),
          const SizedBox(height: 18),
          Text('Yêu cầu', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(job.requirements),
          const SizedBox(height: 18),
          Text('Quyền lợi', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(job.benefits),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () async {
              if (canApplyInternal) {
                final wasApplied = ref
                    .read(appliedJobsProvider)
                    .maybeWhen(data: (items) => items.any((item) => item.jobId == job.id), orElse: () => false);
                await ref.read(appliedJobsProvider.notifier).apply(job);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      wasApplied
                          ? 'Bạn đã ứng tuyển công việc này trước đó.'
                          : 'Đã ghi nhận ứng tuyển. Xem ở mục Lịch sử ứng tuyển.',
                    ),
                  ),
                );
              } else {
                _openApplyUrl(context);
              }
            },
            icon: Icon(canApplyInternal ? Icons.send : Icons.open_in_new),
            label: Text(canApplyInternal ? 'Ứng tuyển trong app' : 'Mở link ứng tuyển'),
          ),
        ],
      ),
    );
  }
}
