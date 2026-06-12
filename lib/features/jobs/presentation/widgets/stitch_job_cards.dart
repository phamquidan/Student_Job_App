import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/stitch_colors.dart';
import '../../domain/job_model.dart';

class StitchFeaturedJobCard extends StatelessWidget {
  const StitchFeaturedJobCard({
    super.key,
    required this.job,
    required this.onApply,
    required this.onBookmark,
    this.isBookmarked = false,
  });

  final JobModel job;
  final VoidCallback onApply;
  final VoidCallback onBookmark;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StitchColors.surfaceContainer),
        boxShadow: const [
          BoxShadow(
            color: StitchColors.ambientShadow,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('Dành cho SV', bg: StitchColors.tertiary.withValues(alpha: 0.12), fg: StitchColors.tertiary),
              _chip('Nổi bật', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StitchColors.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.business, size: 20, color: StitchColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.companyName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: StitchColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: StitchColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  job.location,
                  style: GoogleFonts.inter(color: StitchColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: StitchColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments_outlined, color: StitchColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MỨC LƯƠNG',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: StitchColors.outline,
                      ),
                    ),
                    Text(
                      job.salaryText,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: StitchColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onBookmark,
                style: IconButton.styleFrom(
                  backgroundColor: StitchColors.background,
                  foregroundColor: isBookmarked ? StitchColors.primary : StitchColors.outline,
                ),
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: StitchColors.brandGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onApply,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Ứng tuyển nhanh',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              color: StitchColors.onPrimary,
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
        ],
      ),
    );
  }

  static Widget _chip(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: fg,
        ),
      ),
    );
  }
}

class StitchJobRowCard extends StatelessWidget {
  const StitchJobRowCard({
    super.key,
    required this.job,
    required this.onDetails,
    required this.onBookmark,
    this.isBookmarked = false,
  });

  final JobModel job;
  final VoidCallback onDetails;
  final VoidCallback onBookmark;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StitchColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
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
                      color: StitchColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.apartment_rounded, color: StitchColors.primary.withValues(alpha: 0.85), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: StitchColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${job.companyName} • ${job.location}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                            color: StitchColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LƯƠNG / CHẾ ĐỘ',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: StitchColors.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.salaryText,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: StitchColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? StitchColors.primary : StitchColors.outline,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: StitchColors.primary,
                      side: BorderSide(color: StitchColors.primary.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: Text('Chi tiết', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
