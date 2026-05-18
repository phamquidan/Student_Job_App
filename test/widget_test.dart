import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_job_app/app/app.dart';
import 'package:student_job_app/core/config/app_strings.dart';

void main() {
  testWidgets('app starts and shows brand name', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StudentJobApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AppStrings.appName), findsWidgets);
  });
}
