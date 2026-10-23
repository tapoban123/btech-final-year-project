import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';

void main() {
  testWidgets('Dashboard loads and displays OmniDoc header and library',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OmniDocApp());
    // Allow asynchronous mock API delay timer to finish
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify OmniDoc brand & HUB tag
    expect(find.text('OmniDoc'), findsOneWidget);
    expect(find.text('HUB'), findsOneWidget);

    // Verify My Library header
    expect(find.text('My Library'), findsOneWidget);
  });
}
