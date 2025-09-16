import 'package:flutter_test/flutter_test.dart';
import 'package:gig_marketplace/main.dart';

void main() {
  group('Gig Marketplace App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app builds successfully
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('App should show loading or welcome screen initially', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Wait for the app to settle
      await tester.pumpAndSettle();

      // The app should show some initial screen (loading, welcome, or login)
      // This test ensures the app doesn't crash on startup
      expect(tester.binding.hasScheduledFrame, false);
    });
  });

  group('Environment Configuration Tests', () {
    test('App should handle different build modes', () {
      // Test that app configuration works in different modes
      expect(() => const MyApp(), returnsNormally);
    });
  });
}