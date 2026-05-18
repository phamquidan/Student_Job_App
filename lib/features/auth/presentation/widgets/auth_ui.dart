import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/stitch_colors.dart';

class AuthCardScaffold extends StatelessWidget {
  const AuthCardScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              decoration: BoxDecoration(
                color: StitchColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: StitchColors.ambientShadow,
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSectionLabel extends StatelessWidget {
  const AuthSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: StitchColors.onSurfaceVariant,
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null || isLoading;
    return Opacity(
      opacity: isDisabled ? 0.75 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: StitchColors.ctaGradient,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: isDisabled ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
