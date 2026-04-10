import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/applied_jobs_provider.dart';

class AppliedJobsScreen extends ConsumerWidget {
  const AppliedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appliedJobs = ref.watch(appliedJobsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử ứng tuyển'),
        actions: [
          IconButton(
            onPressed: () => ref.read(appliedJobsProvider.notifier).clearAll(),
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Xóa toàn bộ',
          ),
        ],
      ),
      body: appliedJobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Không tải được lịch sử ứng tuyển: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Bạn chưa ứng tuyển công việc nào. Hãy chọn một việc và thử ứng tuyển trong app.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(item.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${item.companyName}\n${item.location}\nỨng tuyển lúc: ${dateFormat.format(item.appliedAt)}',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    onPressed: () => ref.read(appliedJobsProvider.notifier).remove(item.applicationId),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Xóa khỏi lịch sử',
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
