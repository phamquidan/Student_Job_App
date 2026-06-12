import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/cv_utils.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/config/job_ui_labels.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/widgets/stitch_glass_app_bar.dart';

class _ApplicantItem {
  const _ApplicantItem({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.name,
    required this.email,
    required this.title,
    required this.companyName,
    required this.location,
    required this.status,
    required this.appliedAt,
    this.cvName,
    this.cvDownloadUrl,
    this.cvFileBase64,
  });

  final String id;
  final String jobId;
  final String userId;
  final String name;
  final String email;
  final String title;
  final String companyName;
  final String location;
  final String status;
  final DateTime appliedAt;
  final String? cvName;
  final String? cvDownloadUrl;
  final String? cvFileBase64;
}

typedef _RecruiterJobSummary = ({
  String id,
  String title,
  String jobType,
  String location,
  String companyName,
});

class ApplicantsListScreen extends StatefulWidget {
  const ApplicantsListScreen({super.key, this.selectedJobId});

  final String? selectedJobId;

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  String _sort = 'newest';
  late String _selectedJobId;

  @override
  void initState() {
    super.initState();
    _selectedJobId = widget.selectedJobId ?? 'all';
  }

  Stream<List<_RecruiterJobSummary>> _recruiterJobsStream() {
    if (!AppConfig.isFirebaseEnabled || FirebaseAuth.instance.currentUser == null) {
      return Stream.value(const <_RecruiterJobSummary>[]);
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('createdBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return (
                id: doc.id,
                title: data['title']?.toString() ?? 'Tin tuyển dụng',
                jobType: data['jobType']?.toString() ?? '',
                location: data['location']?.toString() ?? '',
                companyName: data['companyName']?.toString() ?? '',
              );
            })
            .toList());
  }

  Stream<List<_ApplicantItem>> _applicationsStream(Set<String> recruiterJobIds) {
    if (!AppConfig.isFirebaseEnabled) {
      return Stream.value(const <_ApplicantItem>[]);
    }
    
    if (_selectedJobId == 'all' && recruiterJobIds.isEmpty) {
      return Stream.value(const <_ApplicantItem>[]);
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('applications')
        .orderBy('appliedAt', descending: true);
        
    if (_selectedJobId != 'all') {
      query = query.where('jobId', isEqualTo: _selectedJobId);
    } else {
      query = query.where('jobId', whereIn: recruiterJobIds.toList());
    }

    return query
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['appliedAt'];
            final appliedAt = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
            return _ApplicantItem(
              id: doc.id,
              jobId: data['jobId']?.toString() ?? '',
              userId: data['userId']?.toString() ?? '',
              name: data['applicantName']?.toString() ?? 'Ứng viên',
              email: data['applicantEmail']?.toString() ?? '',
              title: data['title']?.toString() ?? '',
              companyName: data['companyName']?.toString() ?? '',
              location: data['location']?.toString() ?? '',
              status: data['status']?.toString() ?? 'submitted',
              appliedAt: appliedAt,
              cvName: data['cvName']?.toString(),
              cvDownloadUrl: data['cvDownloadUrl']?.toString(),
              cvFileBase64: data['cvFileBase64']?.toString(),
            );
          }).toList();

          if (_sort == 'newest') {
            items.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          } else if (_sort == 'match') {
            items.sort((a, b) => _statusRank(a.status).compareTo(_statusRank(b.status)));
          }
          return items;
        });
  }

  static int _statusRank(String status) {
    switch (status) {
      case 'interview':
        return 0;
      case 'reviewing':
        return 1;
      case 'submitted':
      default:
        return 2;
    }
  }

  Future<void> _updateStatus(_ApplicantItem item, String status, String? feedback) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final rootRef = FirebaseFirestore.instance.collection('applications').doc(item.id);
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(item.userId)
          .collection('applications')
          .doc(item.id);
      
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'feedback': feedback ?? '',
        'feedbackAt': feedback != null ? FieldValue.serverTimestamp() : null,
      };

      batch.set(rootRef, updateData, SetOptions(merge: true));
      batch.set(userRef, updateData, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật trạng thái ứng viên thành công.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không cập nhật được trạng thái: $e')),
      );
    }
  }

  Future<void> _showStatusUpdateDialog(_ApplicantItem item, String newStatus) async {
    final feedbackController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cập nhật trạng thái: ${newStatus == "interview" ? "Phỏng vấn" : newStatus == "reviewing" ? "Đang xem xét" : "Đã nộp"}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gửi kèm phản hồi hoặc thông tin (ví dụ: ngày giờ phỏng vấn, liên kết Zoom/lý do...):'),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú phản hồi cho ứng viên (tùy chọn)...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final feedback = feedbackController.text.trim();
      await _updateStatus(item, newStatus, feedback.isNotEmpty ? feedback : null);
    }
  }

  Future<void> _openPrimaryCv(_ApplicantItem item) async {
    try {
      String url = '';
      String base64Str = '';
      String filename = 'CV.pdf';

      if ((item.cvDownloadUrl != null && item.cvDownloadUrl!.isNotEmpty) ||
          (item.cvFileBase64 != null && item.cvFileBase64!.isNotEmpty)) {
        url = item.cvDownloadUrl ?? '';
        base64Str = item.cvFileBase64 ?? '';
        filename = item.cvName ?? 'CV.pdf';
      } else {
        // Fallback for older application documents
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(item.userId)
            .collection('cvs')
            .where('isPrimary', isEqualTo: true)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ứng viên chưa đính kèm CV.')),
          );
          return;
        }
        
        final docData = snapshot.docs.first.data();
        url = docData['downloadUrl']?.toString() ?? '';
        base64Str = docData['fileBase64']?.toString() ?? '';
        filename = docData['name']?.toString() ?? 'CV.pdf';
      }

      String targetUrl = '';
      if (url.isNotEmpty && !url.contains('base64')) {
        targetUrl = url;
      } else if (base64Str.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang chuẩn bị xem CV trực tuyến...'), duration: Duration(seconds: 2)),
          );
        }
        targetUrl = await CvUtils.uploadBase64ToTmpFiles(base64Str, filename);
      }

      if (targetUrl.isNotEmpty) {
        // Sử dụng Google Docs Viewer để xem trực tuyến trên di động mà không tải về máy
        final viewerUrl = 'https://docs.google.com/viewer?url=${Uri.encodeComponent(targetUrl)}';
        final uri = Uri.tryParse(viewerUrl);
        if (uri == null) return;
        
        final ok = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không mở được CV.')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dữ liệu CV của ứng viên không hợp lệ.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lấy được CV: $e')),
      );
    }
  }

  Widget _buildHeader({
    required _RecruiterJobSummary? selectedJob,
    required int applicantCount,
  }) {
    final title = selectedJob?.title ?? AppStrings.allApplicantsTitle;
    final tags = <Widget>[];

    if (selectedJob != null) {
      if (selectedJob.jobType.isNotEmpty) {
        tags.add(_tag(
          JobUiLabels.postTypeLabel(selectedJob.jobType),
          StitchColors.secondaryContainer,
          StitchColors.onSecondaryContainer,
        ));
      }
      if (selectedJob.location.isNotEmpty) {
        tags.add(_tag(
          selectedJob.location,
          StitchColors.surfaceContainerHigh,
          StitchColors.onSurface,
        ));
      }
      if (selectedJob.companyName.isNotEmpty) {
        tags.add(_tag(
          selectedJob.companyName,
          StitchColors.secondaryContainer,
          StitchColors.onSecondaryContainer,
        ));
      }
    }

    tags.add(_tag(
      '$applicantCount ứng viên',
      StitchColors.tertiaryContainer,
      StitchColors.onTertiaryContainer,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text(AppStrings.backLabel),
          style: TextButton.styleFrom(foregroundColor: StitchColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w800, height: 1.1),
        ),
        if (selectedJob == null) ...[
          const SizedBox(height: 6),
          Text(
            'Danh sách ứng viên cho tất cả tin bạn đã đăng.',
            style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: StitchColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20, color: StitchColors.outline),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sort,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                      DropdownMenuItem(value: 'exp', child: Text('Kinh nghiệm')),
                      DropdownMenuItem(value: 'match', child: Text('Độ khớp')),
                    ],
                    onChanged: (v) => setState(() => _sort = v ?? _sort),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StitchGlassBackBar(title: 'Ứng viên'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: StreamBuilder<List<_RecruiterJobSummary>>(
                stream: _recruiterJobsStream(),
                builder: (context, jobsSnapshot) {
                  final jobs = jobsSnapshot.data ?? const <_RecruiterJobSummary>[];
                  final recruiterJobIds = jobs.map((job) => job.id).toSet();
                  _RecruiterJobSummary? selectedJob;
                  if (_selectedJobId != 'all') {
                    for (final job in jobs) {
                      if (job.id == _selectedJobId) {
                        selectedJob = job;
                        break;
                      }
                    }
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<List<_ApplicantItem>>(
                              stream: _applicationsStream(recruiterJobIds),
                              builder: (context, appsSnapshot) {
                                final count = appsSnapshot.data?.length ?? 0;
                                return _buildHeader(
                                  selectedJob: selectedJob,
                                  applicantCount: count,
                                );
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: StitchColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.work_outline,
                                    size: 20,
                                    color: StitchColors.outline,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: jobs.any((job) => job.id == _selectedJobId) || _selectedJobId == 'all'
                                            ? _selectedJobId
                                            : 'all',
                                        isExpanded: true,
                                        items: [
                                          const DropdownMenuItem(
                                            value: 'all',
                                            child: Text('Tất cả tin đăng'),
                                          ),
                                          for (final job in jobs)
                                            DropdownMenuItem(
                                              value: job.id,
                                              child: Text(job.title),
                                            ),
                                        ],
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() => _selectedJobId = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StreamBuilder<List<_ApplicantItem>>(
                          stream: _applicationsStream(recruiterJobIds),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final items = snapshot.data ?? const <_ApplicantItem>[];
                            final isAllJobs = _selectedJobId == 'all';
                            final countLabel = _selectedJobId == 'all'
                                ? 'Tổng ứng viên: ${items.length}'
                                : 'Ứng viên cho tin đã chọn: ${items.length}';
                            if (items.isNotEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isAllJobs
                                            ? StitchColors.secondaryContainer
                                            : StitchColors.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        countLabel,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: isAllJobs
                                              ? StitchColors.onSecondaryContainer
                                              : StitchColors.onTertiaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  for (final item in items) ...[
                                    _ApplicantCard(
                                      data: item,
                                      onStatusChange: (status) => _showStatusUpdateDialog(item, status),
                                      onViewCv: () => _openPrimaryCv(item),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ],
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                jobs.isEmpty
                                    ? 'Bạn chưa có tin đăng nào. Hãy đăng tin trước để nhận ứng viên.'
                                    : 'Chưa có ứng viên nào. Đơn ứng tuyển sẽ hiển thị ở đây khi sinh viên ứng tuyển.',
                                style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.data,
    required this.onStatusChange,
    required this.onViewCv,
  });

  final _ApplicantItem data;
  final ValueChanged<String> onStatusChange;
  final VoidCallback onViewCv;

  (String, Color) _statusTextAndColor(String status) {
    switch (status) {
      case 'interview':
        return ('PHỎNG VẤN', StitchColors.primary);
      case 'reviewing':
        return ('ĐANG XEM XÉT', const Color(0xFFD97706));
      case 'submitted':
      default:
        return ('ĐÃ NỘP', StitchColors.outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusTextAndColor(data.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: StitchColors.surfaceContainerLow,
                ),
                child: Icon(Icons.person_rounded, color: StitchColors.primary.withValues(alpha: 0.85), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(data.email, style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, fontSize: 13)),
                    Text(
                      '${data.title} • ${data.companyName}'.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: StitchColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data.location,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: StitchColors.onSurface,
                      height: 1,
                    ),
                  ),
                  Text(
                    'ỨNG TUYỂN',
                    style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: StitchColors.outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusInfo.$2, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                statusInfo.$1,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: statusInfo.$2,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onViewCv,
                child: const Text('Xem CV'),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: onStatusChange,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'submitted', child: Text('Đã nộp')),
                  PopupMenuItem(value: 'reviewing', child: Text('Đang xem xét')),
                  PopupMenuItem(value: 'interview', child: Text('Phỏng vấn')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: StitchColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Cập nhật',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
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
