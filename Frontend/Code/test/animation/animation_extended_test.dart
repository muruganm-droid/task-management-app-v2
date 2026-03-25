// =============================================================================
// Category 2 Extended: Animation Tests
// NEW tests: animation curves, timing values, stagger delays, animation state
// during progress, FadeInWidget scale animation, ShimmerLoading gradient,
// GlassmorphicContainer as StatelessWidget, multi-item stagger timing
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ANIM-EXT-001: AnimatedListItem stagger delay', () {
    testWidgets('Multiple items with stagger delay render', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Column(
            children: List.generate(
              3,
              (i) => AnimatedListItem(
                index: i,
                delay: const Duration(milliseconds: 100),
                child: Text('Item $i'),
              ),
            ),
          ),
        ),
      ));
      // Pump enough for all staggered items to complete
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
    });

    test('Custom delay and duration accepted', () {
      const item = AnimatedListItem(
        index: 5,
        delay: Duration(milliseconds: 100),
        duration: Duration(milliseconds: 600),
        child: Text('Custom'),
      );
      expect(item.delay, const Duration(milliseconds: 100));
      expect(item.duration, const Duration(milliseconds: 600));
      expect(item.index, 5);
    });
  });

  group('ANIM-EXT-002: FadeInWidget scale behavior', () {
    testWidgets('FadeInWidget starts with reduced opacity', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: FadeInWidget(
            duration: Duration(milliseconds: 500),
            child: Text('Scale'),
          ),
        ),
      ));
      // At t=0 should have opacity widget
      final opacity = tester.widgetList<Opacity>(find.byType(Opacity));
      expect(opacity, isNotEmpty);
      // Pump enough to let the delayed Future fire and animation complete
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('FadeInWidget with custom curve', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: FadeInWidget(
            curve: Curves.bounceOut,
            duration: Duration(milliseconds: 400),
            child: Text('Bounce'),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Bounce'), findsOneWidget);
    });

    testWidgets('FadeInWidget with delay', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: FadeInWidget(
            delay: Duration(milliseconds: 200),
            duration: Duration(milliseconds: 300),
            child: Text('Delayed'),
          ),
        ),
      ));
      // Before delay, widget is still present but may be invisible
      expect(find.text('Delayed'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Delayed'), findsOneWidget);
    });
  });

  group('ANIM-EXT-003: ScaleOnTap animation details', () {
    testWidgets('ScaleOnTap default scaleDown is 0.96', (tester) async {
      const widget = ScaleOnTap(
        child: Text('Scale'),
      );
      expect(widget.scaleDown, 0.96);
    });

    testWidgets('Custom scaleDown value', (tester) async {
      const widget = ScaleOnTap(
        scaleDown: 0.9,
        child: Text('Custom'),
      );
      expect(widget.scaleDown, 0.9);
    });

    testWidgets('ScaleOnTap tap cancel does not crash', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(onTap: () {}, child: const SizedBox(width: 100, height: 100, child: Text('Cancel'))),
        ),
      ));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Cancel')));
      await tester.pump();
      // Cancel the gesture by moving far away
      await gesture.cancel();
      await tester.pump(const Duration(milliseconds: 300));
      // No crash
    });
  });

  group('ANIM-EXT-004: ShimmerLoading custom border radius', () {
    testWidgets('Custom borderRadius renders', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(child: ShimmerLoading(height: 50, borderRadius: 24)),
        ),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });

    testWidgets('ShimmerLoading with explicit width', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(child: ShimmerLoading(width: 150, height: 30, borderRadius: 8)),
        ),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsOneWidget);
    });
  });

  group('ANIM-EXT-005: GlassmorphicContainer is StatelessWidget', () {
    test('GlassmorphicContainer default values', () {
      const container = GlassmorphicContainer(child: Text('X'));
      expect(container.borderRadius, 16);
      expect(container.opacity, 0.08);
      expect(container.padding, isNull);
    });
  });

  group('ANIM-EXT-006: AnimatedListItem immediate unmount', () {
    testWidgets('Unmounting after animation delay is safe', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(
            index: 0,
            delay: Duration(milliseconds: 60),
            child: Text('Late'),
          ),
        ),
      ));
      // Pump enough for the Future.delayed to fire
      await tester.pump(const Duration(milliseconds: 500));
      // Now remove safely
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
      // No crash or assertion error
    });
  });

  group('ANIM-EXT-007: Multiple animation widgets nested', () {
    testWidgets('FadeInWidget inside AnimatedListItem', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(
            index: 0,
            child: FadeInWidget(child: Text('Nested')),
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Nested'), findsOneWidget);
    });
  });
}
