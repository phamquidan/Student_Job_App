import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final jobsAsync = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Việc đã lưu')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không tải được danh sách đã lưu: $error')),
        data: (favoriteIds) {
          return jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Không tải được danh sách việc làm: $error')),
            data: (jobs) {
              final filtered = jobs.where((job) => favoriteIds.contains(job.id)).toList();
              if (filtered.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Bạn chưa lưu công việc nào. Hãy bấm biểu tượng tim ở màn chi tiết việc làm.'),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final job = filtered[index];
                  return Card(
                    child: ListTile(
                      title: Text(job.title),
                      subtitle: Text('${job.companyName}\n${job.location}'),
                      isThreeLine: true,
                      onTap: () => context.push('/job-detail', extra: job),
                    ),
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
