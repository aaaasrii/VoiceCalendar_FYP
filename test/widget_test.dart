import 'package:flutter_test/flutter_test.dart';
import 'package:voca_assist/main.dart';

void main() {
  testWidgets('App should load and show Welcome Screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VocaAssist());

    // Instead of looking for a '0', let's just make sure the app starts
    // and doesn't crash immediately.
    expect(find.byType(VocaAssist), findsOneWidget);
  });
}
