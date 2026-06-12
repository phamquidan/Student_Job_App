import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_strings.dart';
import '../../../../core/config/job_ui_labels.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../jobs/presentation/providers/jobs_provider.dart';
import '../../../jobs/domain/job_model.dart';
import '../providers/recruiter_jobs_provider.dart';
import '../../../../core/widgets/stitch_glass_app_bar.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  final JobModel? jobToEdit;

  const PostJobScreen({super.key, this.jobToEdit});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  static const List<String> _categories = [
    'Công nghệ thông tin',
    'Marketing',
    'Thiết kế',
    'Kinh doanh',
    'Tài chính / Kế toán',
    'Giáo dục / Sư phạm',
    'Y tế / Y khoa',
    'Du lịch / Khách sạn',
    'Nhân sự (HR)',
    'Logistics / Vận tải',
    'Khác...',
  ];

  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _location = TextEditingController();
  final _salary = TextEditingController();
  final _customCategoryController = TextEditingController();
  String _jobType = 'Internship';
  String _category = 'Công nghệ thông tin';
  final _description = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      final job = widget.jobToEdit!;
      _title.text = job.title;
      _company.text = job.companyName;
      _location.text = job.location;
      _salary.text = job.salaryText;
      _description.text = job.description;
      _jobType = job.jobType;
      if (_categories.contains(job.category)) {
        _category = job.category;
      } else {
        _category = 'Khác...';
        _customCategoryController.text = job.category;
      }
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _location.dispose();
    _salary.dispose();
    _description.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_category == 'Khác...' && _customCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ngành nghề khác.')),
      );
      return;
    }

    final categoryToSave = _category == 'Khác...' ? _customCategoryController.text.trim() : _category;

    setState(() => _isSubmitting = true);
    try {
      if (widget.jobToEdit != null) {
        await ref.read(recruiterJobsRepositoryProvider).updateJob(
              jobId: widget.jobToEdit!.id,
              title: _title.text,
              companyName: _company.text,
              location: _location.text,
              salaryText: _salary.text,
              jobType: _jobType,
              category: categoryToSave,
              description: _description.text,
            );
        ref.invalidate(jobsProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật tin tuyển dụng thành công.')),
        );
        context.pop();
      } else {
        await ref.read(recruiterJobsRepositoryProvider).createJob(
              title: _title.text,
              companyName: _company.text,
              location: _location.text,
              salaryText: _salary.text,
              jobType: _jobType,
              category: categoryToSave,
              description: _description.text,
            );
        ref.invalidate(jobsProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.jobPostValid)),
        );
        _formKey.currentState?.reset();
        _title.clear();
        _company.clear();
        _location.clear();
        _salary.clear();
        _description.clear();
        _customCategoryController.clear();
        setState(() {
          _jobType = 'Internship';
          _category = 'Công nghệ thông tin';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: StitchColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StitchGlassBackBar(
            title: widget.jobToEdit != null ? 'Chỉnh sửa tin' : 'Đăng tin tuyển dụng',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: _formKey,
                child: Container(
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
                    Text(
                      widget.jobToEdit != null ? 'Chỉnh sửa tin đăng' : 'Thông tin tin đăng',
                      style: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.jobToEdit != null
                          ? 'Cập nhật các trường bên dưới để sửa tin tuyển dụng.'
                          : 'Điền các trường bên dưới để tạo tin tuyển dụng.',
                      style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _title,
                      label: 'Tiêu đề',
                      hint: 'Ví dụ: Thực tập sinh Flutter',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _company,
                      label: 'Công ty',
                      hint: 'Ví dụ: ${AppStrings.appName}',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _location,
                      label: 'Địa điểm',
                      hint: 'Ví dụ: TP.HCM (Hybrid)',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _salary,
                      label: 'Lương / mức phụ cấp',
                      hint: 'Ví dụ: 3.000.000 - 5.000.000 VNĐ',
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Loại việc'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _jobType,
                      items: [
                        for (final option in JobUiLabels.postTypeOptions)
                          DropdownMenuItem(value: option.id, child: Text(option.label)),
                      ],
                      onChanged: (value) => setState(() => _jobType = value ?? _jobType),
                      decoration: const InputDecoration(),
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Ngành nghề'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: [
                        for (final cat in _categories)
                          DropdownMenuItem(value: cat, child: Text(cat)),
                      ],
                      onChanged: (value) => setState(() {
                        _category = value ?? _category;
                      }),
                      decoration: const InputDecoration(),
                    ),
                    if (_category == 'Khác...') ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _customCategoryController,
                        label: 'Ngành nghề khác',
                        hint: 'Ví dụ: Y khoa, Sư phạm...',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _description,
                      label: 'Mô tả',
                      hint: 'Mô tả trách nhiệm, yêu cầu và quyền lợi...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: StitchColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Xem nhanh: ${JobUiLabels.postTypeLabel(_jobType)} | $_category',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: StitchColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: StitchColors.ctaGradient,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _isSubmitting ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        widget.jobToEdit != null ? 'Cập nhật tin' : 'Đăng tin',
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
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
