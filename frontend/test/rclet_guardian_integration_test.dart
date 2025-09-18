// Integration test for Rclet Guardian Mascot components
// This file imports all components to verify there are no import errors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import all the mascot-related components
import '../lib/core/components/rclet_guardian_mascot.dart';
import '../lib/shared/widgets/control_center_widget.dart';
import '../lib/shared/widgets/empty_state_widget.dart';

void main() {
  group('Rclet Guardian Mascot Integration Tests', () {
    testWidgets('Mascot widget renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RcletGuardianMascot.buildMascotWidget(
              size: MascotSize.medium,
              state: MascotState.idle,
              showMessage: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('Control Center widget renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ControlCenterWidget(),
          ),
        ),
      );
      
      expect(find.text('Rclet Guardian'), findsOneWidget);
    });

    testWidgets('Agent Status Indicator renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AgentStatusIndicator(),
          ),
        ),
      );
      
      expect(find.text('Rclet Guardian'), findsOneWidget);
    });

    testWidgets('Empty State widget renders without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Test Empty State',
              subtitle: 'This is a test',
            ),
          ),
        ),
      );
      
      expect(find.text('Test Empty State'), findsOneWidget);
      expect(find.text('Rclet Guardian is watching'), findsOneWidget);
    });
  });
}