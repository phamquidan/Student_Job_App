import 'package:flutter/material.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;
  const AppSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
