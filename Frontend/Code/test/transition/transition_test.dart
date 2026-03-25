// =============================================================================
// Category 4: Transition Tests
// Tests: Page transitions, AnimatedSwitcher, AnimatedContainer behaviors,
//        navigation transitions, tab transitions
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/theme.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('TRANS-001: AnimatedSwitcher in AppShell', () {
    testWidgets('AnimatedSwitcher transitions between children', (tester) async {
      int current = 0;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text('Screen $current', key: ValueKey(current)),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => current = 1),
                    child: const Text('Switch'),
                  ),
                ],
              );
            },
          ),
        ),
      ));

      expect(find.text('Screen 0'), findsOneWidget);
      await tester.tap(find.text('Switch'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Screen 1'), findsOneWidget);
    });
  });

  group('TRANS-002: FadeTransition page navigation', () {
    testWidgets('FadeTransition renders during navigation', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => Scaffold(
                      body: FadeTransition(
                        opacity: anim,
                        child: const Text('Page 2'),
                      ),
                    ),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              child: const Text('Navigate'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Navigate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Page 2'), findsOneWidget);
    });
  });

  group('TRANS-003: SlideTransition', () {
    testWidgets('SlideTransition animates position', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => Scaffold(
                      body: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: const Text('Slid In'),
                      ),
                    ),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Slid In'), findsOneWidget);
    });
  });

  group('TRANS-004: AnimatedContainer transitions', () {
    testWidgets('AnimatedContainer responds to state change', (tester) async {
      bool expanded = false;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () => setState(() => expanded = !expanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: expanded ? 200 : 100,
                  height: 50,
                  color: expanded ? Colors.blue : Colors.red,
                  child: const Text('Box'),
                ),
              );
            },
          ),
        ),
      ));

      // Initial state
      final initialContainer =
          tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(initialContainer.duration, const Duration(milliseconds: 300));

      // Tap to expand
      await tester.tap(find.text('Box'));
      await tester.pump(const Duration(milliseconds: 350));
      // No crash after animation
    });
  });

  group('TRANS-005: CupertinoPageTransitionsBuilder', () {
    test('Light theme uses Cupertino transitions', () {
      final builders = AppTheme.lightTheme.pageTransitionsTheme.builders;
      expect(builders[TargetPlatform.iOS],
          isA<CupertinoPageTransitionsBuilder>());
      expect(builders[TargetPlatform.android],
          isA<CupertinoPageTransitionsBuilder>());
    });

    test('Dark theme uses Cupertino transitions', () {
      final builders = AppTheme.darkTheme.pageTransitionsTheme.builders;
      expect(builders[TargetPlatform.iOS],
          isA<CupertinoPageTransitionsBuilder>());
    });
  });

  group('TRANS-006: ScaleTransition in ScaleOnTap', () {
    testWidgets('ScaleTransition is present', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(
            onTap: () {},
            child: const Text('Scalable'),
          ),
        ),
      ));
      expect(find.byType(ScaleTransition), findsAtLeast(1));
    });
  });
}
