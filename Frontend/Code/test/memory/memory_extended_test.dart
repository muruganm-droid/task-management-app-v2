// =============================================================================
// Category 7 Extended: Memory Tests
// NEW tests: rapid widget mount/unmount cycles, nested animation disposal,
// large list widget recycling, GlassmorphicContainer disposal, ShimmerTaskList
// disposal, state object garbage collection patterns, timer cleanup
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';
import 'package:task_management_app/presentation/views/widgets/shimmer_list.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/presentation/views/widgets/priority_badge.dart';
import 'package:task_management_app/presentation/views/widgets/status_badge.dart';
import 'package:task_management_app/data/models/task.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('MEM-EXT-001: Rapid mount/unmount cycles', () {
    testWidgets('AnimatedListItem survives rapid mount/unmount', (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: AnimatedListItem(index: 0, child: Text('Cycle $i')),
          ),
        ));
        // Pump enough to let the Future.delayed fire
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpWidget(
          createTestApp(child: const Scaffold(body: SizedBox())),
        );
        await tester.pump();
      }
      // No crash after 5 rapid cycles
    });

    testWidgets('FadeInWidget survives rapid mount/unmount', (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: FadeInWidget(child: Text('Fade $i')),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(
          createTestApp(child: const Scaffold(body: SizedBox())),
        );
        await tester.pump();
      }
    });

    testWidgets('ScaleOnTap survives rapid mount/unmount', (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: ScaleOnTap(onTap: () {}, child: Text('Scale $i')),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(
          createTestApp(child: const Scaffold(body: SizedBox())),
        );
        await tester.pump();
      }
    });
  });

  group('MEM-EXT-002: Nested animation widget disposal', () {
    testWidgets('FadeInWidget wrapping ScaleOnTap disposes cleanly', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: FadeInWidget(
            child: ScaleOnTap(
              onTap: () {},
              child: const Text('Nested'),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });

    testWidgets('AnimatedListItem wrapping ShimmerLoading disposes', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: AnimatedListItem(
            index: 0,
            child: ShimmerLoading(height: 40),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-EXT-003: ShimmerTaskList disposal', () {
    testWidgets('ShimmerTaskList with many items disposes cleanly', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: ShimmerTaskList(itemCount: 10)),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-EXT-004: GlassmorphicContainer is stateless, no disposal needed', () {
    testWidgets('GlassmorphicContainer mounts and unmounts safely', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: GlassmorphicContainer(child: Text('Glass')),
        ),
      ));
      await tester.pump();
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-EXT-005: TaskCard with complex task data disposal', () {
    testWidgets('TaskCard with subtasks and due date disposes', (tester) async {
      final task = createTestTask(
        title: 'Complex',
        description: 'A long description',
        dueDate: DateTime(2024, 12, 25),
        assigneeIds: ['u-1', 'u-2', 'u-3'],
        subTasks: [
          createTestSubTask(id: 's1', isDone: true),
          createTestSubTask(id: 's2', isDone: false),
        ],
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-EXT-006: EmptyState with action disposal', () {
    testWidgets('EmptyState with action button disposes cleanly', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'Empty',
            subtitle: 'Nothing here',
            actionLabel: 'Create',
            onAction: () {},
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });

  group('MEM-EXT-007: Large model list garbage collection', () {
    test('Creating and discarding 50000 tasks does not hang', () {
      for (int batch = 0; batch < 5; batch++) {
        final tasks = List.generate(
          10000,
          (i) => createTestTask(id: 'task-$batch-$i', title: 'Task $i'),
        );
        expect(tasks.length, 10000);
      }
      // 50000 total created and eligible for GC
    });

    test('Creating and discarding 10000 notifications', () {
      final notifs = List.generate(
        10000,
        (i) => createTestNotification(id: 'n-$i'),
      );
      expect(notifs.length, 10000);
    });
  });

  group('MEM-EXT-008: Navigator deep stack cleanup', () {
    testWidgets('Push 5 pages and pop all back', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                for (int i = 0; i < 5; i++) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(body: Text('Page $i')),
                    ),
                  );
                }
              },
              child: const Text('Push5'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Push5'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Pop all
      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      for (int i = 0; i < 5; i++) {
        if (nav.canPop()) {
          nav.pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }
      }
      expect(find.text('Push5'), findsOneWidget);
    });
  });

  group('MEM-EXT-009: Stateless widget memory patterns', () {
    testWidgets('PriorityBadge mount/unmount has no state leak', (tester) async {
      for (final p in TaskPriority.values) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(body: PriorityBadge(priority: p)),
        ));
        await tester.pump();
      }
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });

    testWidgets('StatusBadge mount/unmount has no state leak', (tester) async {
      for (final s in TaskStatus.values) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(body: StatusBadge(status: s)),
        ));
        await tester.pump();
      }
      await tester.pumpWidget(
        createTestApp(child: const Scaffold(body: SizedBox())),
      );
      await tester.pump();
    });
  });
}
