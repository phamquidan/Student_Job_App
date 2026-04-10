import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_section_title.dart';
import '../providers/jobs_provider.dart';
import '../widgets/job_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncJobs = ref.watch(jobsProvider);
    final filteredJobs = ref.watch(filteredJobsProvider);
    final typeFilter = ref.watch(jobTypeFilterProvider);
    final sourceFilter = ref.watch(sourceFilterProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Việc làm cho sinh viên'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => context.push('/favorites')),
          IconButton(icon: const Icon(Icons.assignment_outlined), onPressed: () => context.push('/applied-jobs')),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.push('/profile')),
        ],
      ),
      body: asyncJobs.when(
        data: (_) => Column(
          children: [
            const AppSectionTitle(title: 'Tìm kiếm & lọc'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => ref.read(jobSearchProvider.notifier).state = value,
                decoration: const InputDecoration(
                  hintText: 'Tìm theo tiêu đề, công ty, địa điểm...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  DropdownButton<String>(
                    value: typeFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả loại việc')),
                      DropdownMenuItem(value: 'internship', child: Text('Internship')),
                      DropdownMenuItem(value: 'part-time', child: Text('Part-time')),
                      DropdownMenuItem(value: 'full-time', child: Text('Full-time')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(jobTypeFilterProvider.notifier).state = value;
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: sourceFilter,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả nguồn')),
                      DropdownMenuItem(value: 'manual', child: Text('Manual')),
                      DropdownMenuItem(value: 'api', child: Text('API')),
                      DropdownMenuItem(value: 'recruiter', child: Text('Recruiter')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(sourceFilterProvider.notifier).state = value;
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredJobs.isEmpty
                  ? const AppEmptyState(message: 'Không tìm thấy công việc phù hợp.')
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(jobsProvider),
                      child: ListView.builder(
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          final job = filteredJobs[index];
                          return JobCard(job: job, onTap: () => context.push('/job-detail', extra: job));
                        },
                      ),
                    ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Lỗi tải dữ liệu: $error')),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Center(
                child: Text('Student Job App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(leading: const Icon(Icons.login), title: const Text('Đăng nhập'), onTap: () => context.push('/login')),
            ListTile(leading: const Icon(Icons.app_registration), title: const Text('Đăng ký'), onTap: () => context.push('/register')),
            if (AppConfig.useFirebase && user != null)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (!context.mounted) return;
                  context.pop();
                },
              ),
            ListTile(leading: const Icon(Icons.work_outline), title: const Text('Quản lý bài đăng'), onTap: () => context.push('/recruiter/manage-posts')),
            ListTile(leading: const Icon(Icons.add_box_outlined), title: const Text('Đăng tin'), onTap: () => context.push('/recruiter/post-job')),
            ListTile(leading: const Icon(Icons.groups_outlined), title: const Text('Danh sách ứng viên'), onTap: () => context.push('/recruiter/applicants')),
          ],
        ),
      ),
    );
  }
}
