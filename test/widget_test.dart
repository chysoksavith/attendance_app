import 'package:flutter_test/flutter_test.dart';
import 'package:attendance/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const AttendanceApp());
    expect(find.text('Attendance'), findsOneWidget);
  });
}
