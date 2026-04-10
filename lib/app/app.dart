import 'package:flutter/material.dart';

import 'router.dart';
import '../core/theme/app_theme.dart';

class StudentJobApp extends StatelessWidget {
  const StudentJobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Student Job App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
