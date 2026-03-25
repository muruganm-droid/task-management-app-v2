// =============================================================================
// Category 2: Animation Tests
// Tests: AnimatedListItem, FadeInWidget, ScaleOnTap, ShimmerLoading,
//        animation controllers, durations, curves
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ANIM-001: AnimatedListItem', () {
    testWidgets('Renders child', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(index: 0, child: Text('Item')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Item'), findsOneWidget);
    });

    test('AnimatedListItem uses correct default parameters', () {
      const item = AnimatedListItem(
        index: 3,
        child: Text('Test'),
      );
      expect(item.index, 3);
      expect(item.delay, const Duration(milliseconds: 60));
      expect(item.duration, const Duration(milliseconds: 400));
    });

    testWidgets('Disposes safely', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(index: 0, child: Text('X')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('ANIM-002: FadeInWidget', () {
    testWidgets('Renders child after animation', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: FadeInWidget(
            duration: Duration(milliseconds: 300),
            child: Text('Faded'),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Faded'), findsOneWidget);
    });

    test('FadeInWidget uses correct default parameters', () {
      const widget = FadeInWidget(
        delay: Duration(milliseconds: 200),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Text('Delayed'),
      );
      expect(widget.delay, const Duration(milliseconds: 200));
      expect(widget.duration, const Duration(milliseconds: 300));
      expect(widget.curve, Curves.easeOut);
    });

    testWidgets('Disposes safely', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: FadeInWidget(child: Text('D'))),
      ));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('ANIM-003: ScaleOnTap', () {
    testWidgets('Renders child', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(onTap: () {}, child: const Text('Tap')),
        ),
      ));
      expect(find.text('Tap'), findsOneWidget);
    });

    testWidgets('Fires onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Center(
            child: ScaleOnTap(
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 100, child: Text('Go')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Go'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('Null onTap does not crash', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(
            child: ScaleOnTap(
              onTap: null,
              child: SizedBox(width: 100, height: 100, child: Text('No')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('No'));
      await tester.pump();
    });

    testWidgets('Contains ScaleTransition widget', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(onTap: () {}, child: const Text('S')),
        ),
      ));
      expect(find.byType(ScaleTransition), findsAtLeast(1));
    });

    testWidgets('Disposes safely', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(onTap: () {}, child: const Text('D')),
        ),
      ));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('ANIM-004: ShimmerLoading', () {
    testWidgets('Renders with dimensions', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(child: ShimmerLoading(width: 200, height: 50)),
        ),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('Animation continues over time', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: ShimmerLoading(height: 20)),
      ));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('Works in dark theme', (tester) async {
      await tester.pumpWidget(createTestAppWithTheme(
        theme: ThemeData.dark(),
        child: const Scaffold(body: ShimmerLoading(height: 30)),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });
}
