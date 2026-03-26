// =============================================================================
// Category 6: Performance Tests
// Tests: Widget build performance, large list rendering, animation frame rates,
//        state rebuild efficiency, filter performance on large datasets
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import 'package:task_management_app/presentation/views/widgets/priority_badge.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PERF-001: Large task list filtering', () {
    late List<Task> largeTasks;

    setUp(() {
      largeTasks = List.generate(
        1000,
        (i) => createTestTask(
          id: 'task-$i',
          title: 'Task $i ${i.isEven ? "important" : "normal"}',
          status: TaskStatus.values[i % TaskStatus.values.length],
          priority: TaskPriority.values[i % TaskPriority.values.length],
          description: i % 3 == 0 ? 'Description for task $i' : null,
        ),
      );
    });

    test('Filter 1000 tasks by status under 50ms', () {
      final sw = Stopwatch()..start();
      final state = TaskState(tasks: largeTasks, statusFilter: TaskStatus.todo);
      final filtered = state.filteredTasks;
      sw.stop();
      expect(filtered, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('Filter 1000 tasks by search under 50ms', () {
      final sw = Stopwatch()..start();
      final state = TaskState(tasks: largeTasks, searchQuery: 'important');
      final filtered = state.filteredTasks;
      sw.stop();
      expect(filtered, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('Combined filters on 1000 tasks under 50ms', () {
      final sw = Stopwatch()..start();
      final state = TaskState(
        tasks: largeTasks,
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
        searchQuery: 'Task',
      );
      final filteredResult = state.filteredTasks;
      sw.stop();
      expect(filteredResult, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('taskCountByStatus on 1000 tasks under 10ms', () {
      final state = TaskState(tasks: largeTasks);
      final sw = Stopwatch()..start();
      final counts = state.taskCountByStatus;
      sw.stop();
      expect(counts.values.reduce((a, b) => a + b), 1000);
      expect(sw.elapsedMilliseconds, lessThan(10));
    });
  });

  group('PERF-002: Model serialization performance', () {
    test('Parse 500 tasks from JSON under 100ms', () {
      final jsonList = List.generate(500, (i) => {
        'id': 'task-$i',
        'projectId': 'p-1',
        'title': 'Task $i',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });

      final sw = Stopwatch()..start();
      final tasks = jsonList.map((j) => Task.fromJson(j)).toList();
      sw.stop();
      expect(tasks.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  group('PERF-003: Widget rendering', () {
    testWidgets('Renders multiple PriorityBadges', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ListView.builder(
            itemCount: 20,
            itemBuilder: (_, i) => PriorityBadge(
              priority: TaskPriority.values[i % TaskPriority.values.length],
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(PriorityBadge), findsWidgets);
    });

    testWidgets('Renders 10 TaskCards', (tester) async {
      final tasks = List.generate(
        10,
        (i) => createTestTask(id: 'task-$i', title: 'Task $i'),
      );

      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, i) => TaskCard(task: tasks[i]),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(TaskCard), findsWidgets);
    });
  });

  group('PERF-004: Animation efficiency', () {
    test('AnimatedListItem creation is fast', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        // Simulate creating many animated items
        final _ = AnimatedListItem(index: i, child: Text('Item $i'));
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });

  group('PERF-005: Overdue task computation', () {
    test('isOverdue check on 1000 tasks under 5ms', () {
      final tasks = List.generate(
        1000,
        (i) => createTestTask(
          id: 't-$i',
          dueDate: i.isEven ? DateTime(2020, 1, 1) : DateTime(2099, 1, 1),
          status: TaskStatus.todo,
        ),
      );

      final sw = Stopwatch()..start();
      final overdue = tasks.where((t) => t.isOverdue).toList();
      sw.stop();
      expect(overdue.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(5));
    });
  });
}
