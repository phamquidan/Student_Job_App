import 'package:flutter/material.dart';

import '../theme/stitch_colors.dart';

typedef ApplicationStatusStyle = ({String label, Color background, Color foreground});

abstract final class ApplicationStatusUi {
  static ApplicationStatusStyle forStatus(String status) {
    switch (status) {
      case 'interview':
        return (
          label: 'PHỎNG VẤN',
          background: StitchColors.primaryContainer,
          foreground: StitchColors.primaryDim,
        );
      case 'reviewing':
        return (
          label: 'ĐANG XEM XÉT',
          background: const Color(0xFFFFF3E0),
          foreground: const Color(0xFFD97706),
        );
      case 'submitted':
      default:
        return (
          label: 'ĐÃ NỘP',
          background: StitchColors.secondaryContainer,
          foreground: StitchColors.onSecondaryContainer,
        );
    }
  }
}
