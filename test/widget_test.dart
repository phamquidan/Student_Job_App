import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_job_app/app/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StudentJobApp()));
    expect(find.text('Việc làm cho sinh viên'), findsOneWidget);
  });
}
