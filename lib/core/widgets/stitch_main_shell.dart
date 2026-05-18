import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../theme/stitch_colors.dart';

class StitchMainShell extends StatelessWidget {
  const StitchMainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_NavDest>[
    _NavDest(label: 'Trang chủ', icon: Icons.home_outlined, selectedIcon: Icons.home),
    _NavDest(label: 'Khám phá', icon: Icons.search, selectedIcon: Icons.search),
    _NavDest(label: 'Đã lưu', icon: Icons.bookmark_border, selectedIcon: Icons.bookmark),
    _NavDest(label: 'Hồ sơ', icon: Icons.person_outline, selectedIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: Material(
          elevation: 8,
          shadowColor: StitchColors.primary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => context.push(AppRoutes.appliedJobs),
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: StitchColors.brandGradient,
              ),
              child: const Icon(Icons.bolt, color: StitchColors.onPrimary, size: 28),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
        surfaceTintColor: Colors.transparent,
        shadowColor: StitchColors.ambientShadow,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      ),
    );
  }
}

class _NavDest {
  const _NavDest({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
