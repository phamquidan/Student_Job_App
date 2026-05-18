import 'package:flutter/material.dart';

/// Tokens aligned with `stitch/stitch/*/code.html` Tailwind extensions.
abstract final class StitchColors {
  static const Color background = Color(0xFFDBFFE8);
  static const Color surface = Color(0xFFDBFFE8);
  static const Color surfaceContainer = Color(0xFFB8F6D2);
  static const Color surfaceContainerLow = Color(0xFFC5FEDC);
  static const Color surfaceContainerHigh = Color(0xFFAFF1CB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF006A33);
  static const Color onPrimary = Color(0xFFCDFFD3);
  static const Color primaryContainer = Color(0xFF43F588);
  static const Color primaryDim = Color(0xFF005C2C);

  static const Color secondary = Color(0xFF006945);
  static const Color onSecondary = Color(0xFFC9FFDF);
  static const Color secondaryContainer = Color(0xFF74FBBC);
  static const Color onSecondaryContainer = Color(0xFF005E3E);

  static const Color tertiary = Color(0xFFA53232);
  static const Color tertiaryContainer = Color(0xFFFF928B);
  static const Color onTertiaryContainer = Color(0xFF68010C);

  static const Color onSurface = Color(0xFF013622);
  static const Color onSurfaceVariant = Color(0xFF36654D);
  static const Color outline = Color(0xFF518167);
  static const Color outlineVariant = Color(0xFF87B89C);

  /// Glass app bar tint from Stitch (`#f8f5ff` @ 70%).
  static const Color glassBar = Color(0xB3F8F5FF);

  static const Color ambientShadow = Color(0x14282B51);

  /// CTA gradient used in Stitch HTML for primary actions (blue variant).
  static const LinearGradient ctaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0050D4), Color(0xFF7B9CFF)],
  );

  /// Brand green gradient (DESIGN.md lithographic CTA).
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006A33), Color(0xFF43F588)],
  );
}
