import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_strings.dart';
import '../../../../core/theme/stitch_colors.dart';
import '../../../../core/widgets/stitch_glass_app_bar.dart';

class _CvFile {
  const _CvFile({
    required this.id,
    required this.name,
    required this.detail,
    required this.downloadUrl,
    required this.storagePath,
    this.primary = false,
  });

  final String id;
  final String name;
  final String detail;
  final String downloadUrl;
  final String storagePath;
  final bool primary;
}

class UploadCvScreen extends StatefulWidget {
  const UploadCvScreen({super.key});

  @override
  State<UploadCvScreen> createState() => _UploadCvScreenState();
}

class _UploadCvScreenState extends State<UploadCvScreen> {
  bool _loading = true;
  bool _uploading = false;
  List<_CvFile> _files = const [];

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    if (!AppConfig.isFirebaseEnabled || _auth.currentUser == null) {
      setState(() {
        _files = const [];
        _loading = false;
      });
      return;
    }

    try {
      final uid = _auth.currentUser!.uid;
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('cvs')
          .orderBy('uploadedAt', descending: true)
          .get();

      final files = snapshot.docs.map((doc) {
        final data = doc.data();
        final uploadedAt = data['uploadedAt'];
        final uploadedAtText = uploadedAt is Timestamp
            ? _formatUploadedAt(uploadedAt.toDate())
            : 'Vừa tải lên';
        final sizeBytes = (data['sizeBytes'] as num?)?.toInt() ?? 0;
        return _CvFile(
          id: doc.id,
          name: data['name']?.toString() ?? 'CV',
          detail: '$uploadedAtText • ${_formatBytes(sizeBytes)}',
          downloadUrl: data['downloadUrl']?.toString() ?? '',
          storagePath: data['storagePath']?.toString() ?? '',
          primary: (data['isPrimary'] as bool?) ?? false,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _files = files;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được danh sách CV: $e')),
      );
    }
  }

  String _formatUploadedAt(DateTime dt) {
    return 'Cập nhật ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(index == 0 ? 0 : 1)} ${units[index]}';
  }

  Future<void> _pickAndUpload() async {
    if (!AppConfig.isFirebaseEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase chưa sẵn sàng.')),
      );
      return;
    }
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để tải CV.')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: const ['pdf', 'doc', 'docx'],
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final file = result.files.first;

    setState(() => _uploading = true);
    try {
      final ext = (file.extension ?? '').toLowerCase();
      final now = DateTime.now().millisecondsSinceEpoch;
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'cvs/${user.uid}/$now-$safeName';
      final ref = _storage.ref(path);
      final metadata = SettableMetadata(
        contentType: ext == 'pdf'
            ? 'application/pdf'
            : ext == 'doc'
                ? 'application/msword'
                : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      );

      if (file.bytes != null) {
        await ref.putData(file.bytes!, metadata);
      } else if (file.path != null) {
        await ref.putFile(
          // ignore: avoid_redundant_argument_values
          File(file.path!),
          metadata,
        );
      } else {
        throw StateError('Không đọc được dữ liệu file.');
      }

      final url = await ref.getDownloadURL();
      final cvDoc = _firestore.collection('users').doc(user.uid).collection('cvs').doc();

      final hadPrimary = _files.any((f) => f.primary);
      await cvDoc.set({
        'name': file.name,
        'sizeBytes': file.size,
        'storagePath': path,
        'downloadUrl': url,
        'isPrimary': !hadPrimary,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.filePickedPrefix} ${file.name}')),
      );
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tải CV thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _setPrimary(_CvFile file) async {
    final user = _auth.currentUser;
    if (!AppConfig.isFirebaseEnabled || user == null) return;
    try {
      final collection = _firestore.collection('users').doc(user.uid).collection('cvs');
      final batch = _firestore.batch();
      for (final item in _files) {
        final ref = collection.doc(item.id);
        batch.update(ref, {'isPrimary': item.id == file.id});
      }
      await batch.commit();
      await _loadFiles();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không cập nhật được CV chính: $e')),
      );
    }
  }

  Future<void> _openCv(_CvFile file) async {
    final url = Uri.tryParse(file.downloadUrl);
    if (url == null) return;
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được file CV.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StitchGlassBackBar(title: AppStrings.cvHubTitle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KIẾN TẠO SỰ NGHIỆP',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: StitchColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.cvHubTitle,
                    style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, height: 1.05),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Quản lý nhiều phiên bản CV và chọn bản chính để nhà tuyển dụng xem.',
                    style: GoogleFonts.inter(fontSize: 15, color: StitchColors.onSurfaceVariant, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: StitchColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StitchColors.outlineVariant.withValues(alpha: 0.35), width: 2),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: StitchColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.cloud_upload_rounded, size: 36, color: StitchColors.secondary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kéo thả hoặc chọn file CV',
                          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'PDF, DOCX (tối đa 5MB)',
                          style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 18),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: StitchColors.ctaGradient,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _uploading ? null : _pickAndUpload,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _uploading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.add, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      _uploading ? 'Đang tải lên...' : 'Chọn file để tải lên',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tài liệu gần đây',
                        style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${_files.length} file',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: StitchColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_files.isEmpty)
                    Text(
                      'Bạn chưa có CV nào. Hãy tải lên CV đầu tiên.',
                      style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                    )
                  else
                    for (final f in _files) ...[
                      _DocumentRow(
                        file: f,
                        onOpen: () => _openCv(f),
                        onSetPrimary: f.primary ? null : () => _setPrimary(f),
                      ),
                      const SizedBox(height: 12),
                    ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: StitchColors.tertiaryContainer.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, color: StitchColors.tertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cập nhật hồ sơ năng lực mới nhất để tăng lượt xem hồ sơ.',
                            style: GoogleFonts.inter(fontSize: 13, color: StitchColors.onSurfaceVariant, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.file,
    required this.onOpen,
    required this.onSetPrimary,
  });

  final _CvFile file;
  final VoidCallback onOpen;
  final VoidCallback? onSetPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: StitchColors.ambientShadow, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: file.primary
                  ? StitchColors.primaryContainer.withValues(alpha: 0.25)
                  : StitchColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.description_outlined,
              color: file.primary ? StitchColors.primary : StitchColors.onSurfaceVariant,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        file.name,
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (file.primary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: StitchColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'CHÍNH',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: StitchColors.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(file.detail, style: GoogleFonts.inter(fontSize: 12, color: StitchColors.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(onPressed: onOpen, icon: const Icon(Icons.visibility_outlined)),
          if (!file.primary)
            TextButton(
              onPressed: onSetPrimary,
              child: Text(
                'Đặt làm chính',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: StitchColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
