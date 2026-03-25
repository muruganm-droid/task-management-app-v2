// =============================================================================
// Category 7: Memory Tests
// Tests: Controller disposal, animation controller lifecycle, widget unmount
//        cleanup, state object cleanup, large data handling
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/data/models/task.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('MEM-001: AnimatedListItem disposal', () {
    testWidgets('Disposes controller on unmount', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(index: 0, child: Text('A')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
      // No assertion error means controller disposed properly
    });

    testWidgets('Multiple items dispose without error', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Column(
            children: List.generate(
              5,
              (i) => AnimatedListItem(index: i, child: Text('Item $i')),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 800));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-002: FadeInWidget disposal', () {
    testWidgets('Disposes without leaks', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: FadeInWidget(child: Text('Fade')),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 600));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-003: ScaleOnTap disposal', () {
    testWidgets('Disposes without leaks', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ScaleOnTap(onTap: () {}, child: const Text('S')),
        ),
      ));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-004: ShimmerLoading disposal', () {
    testWidgets('Repeating animation disposes', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: ShimmerLoading(height: 20)),
      ));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-005: EmptyState floating animation disposal', () {
    testWidgets('Floating animation controller disposes', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: EmptyState(icon: Icons.inbox, title: 'Empty'),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-006: TaskCard animation disposal', () {
    testWidgets('TaskCard scale controller disposes', (tester) async {
      final task = createTestTask(title: 'Card');
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: TaskCard(task: task)),
      ));
      await tester.pump();

      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-007: Large data handling', () {
    test('Creating 10000 tasks does not OOM', () {
      final tasks = List.generate(
        10000,
        (i) => createTestTask(id: 'task-$i', title: 'Task $i'),
      );
      expect(tasks.length, 10000);
    });

    test('Filtering 10000 tasks completes', () {
      final tasks = List.generate(
        10000,
        (i) => createTestTask(
          id: 'task-$i',
          title: 'Task $i',
          status: i.isEven ? TaskStatus.todo : TaskStatus.done,
        ),
      );
      final filtered = tasks.where((t) => t.status == TaskStatus.todo).toList();
      expect(filtered.length, 5000);
    });
  });

  group('MEM-008: Navigator stack cleanup', () {
    testWidgets('Pushing and popping pages cleans up', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Text('Page 2')),
                  ),
                );
              },
              child: const Text('Push'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Push'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Page 2'), findsOneWidget);

      // Pop back
      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Push'), findsOneWidget);
    });
  });
}
