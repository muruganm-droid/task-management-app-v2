// =============================================================================
// Category 6 Extended: Performance Tests
// NEW tests: large project list filtering, model batch serialization,
// notification filtering performance, dashboard computation on large data,
// SubTask batch processing, copyWith performance, overdue computation scaling,
// search query performance with special characters
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/analytics.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/notification_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/project_viewmodel.dart';
import 'package:task_management_app/presentation/views/widgets/status_badge.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('PERF-EXT-001: Project batch serialization', () {
    test('Parse 500 projects from JSON under 100ms', () {
      final jsonList = List.generate(500, (i) => {
        'id': 'p-$i',
        'name': 'Project $i',
        'ownerId': 'u-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });

      final sw = Stopwatch()..start();
      final projects = jsonList.map((j) => Project.fromJson(j)).toList();
      sw.stop();
      expect(projects.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  group('PERF-EXT-002: Notification batch processing', () {
    test('Parse 500 notifications under 100ms', () {
      final jsonList = List.generate(500, (i) => {
        'id': 'n-$i',
        'userId': 'u-1',
        'type': 'TASK_ASSIGNED',
        'title': 'Notification $i',
        'body': 'Body $i',
        'isRead': i.isEven,
        'createdAt': '2024-01-01T00:00:00Z',
      });

      final sw = Stopwatch()..start();
      final notifs = jsonList.map((j) => AppNotification.fromJson(j)).toList();
      sw.stop();
      expect(notifs.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(100));
    });

    test('Unread count on 1000 notifications under 5ms', () {
      final notifs = List.generate(
        1000,
        (i) => createTestNotification(id: 'n-$i', isRead: i % 3 == 0),
      );
      final state = NotificationState(notifications: notifs);
      final sw = Stopwatch()..start();
      final count = state.unreadCount;
      sw.stop();
      expect(count, greaterThan(0));
      expect(sw.elapsedMilliseconds, lessThan(5));
    });
  });

  group('PERF-EXT-003: Comment batch serialization', () {
    test('Parse 500 comments under 100ms', () {
      final jsonList = List.generate(500, (i) => {
        'id': 'c-$i',
        'taskId': 't-1',
        'authorId': 'u-1',
        'authorName': 'User $i',
        'body': 'Comment body $i with some longer text for realistic testing',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });

      final sw = Stopwatch()..start();
      final comments = jsonList.map((j) => Comment.fromJson(j)).toList();
      sw.stop();
      expect(comments.length, 500);
      expect(sw.elapsedMilliseconds, lessThan(100));
    });
  });

  group('PERF-EXT-004: ProjectState active/archived filtering', () {
    test('Filter 1000 projects by archived under 10ms', () {
      final projects = List.generate(
        1000,
        (i) => createTestProject(id: 'p-$i', isArchived: i % 5 == 0),
      );
      final state = ProjectState(projects: projects);

      final sw = Stopwatch()..start();
      final active = state.activeProjects;
      final archived = state.archivedProjects;
      sw.stop();
      expect(active.length, 800);
      expect(archived.length, 200);
      expect(sw.elapsedMilliseconds, lessThan(10));
    });
  });

  group('PERF-EXT-005: Dashboard overdueTasks on large list', () {
    test('Overdue computation on 5000 tasks under 20ms', () {
      final tasks = List.generate(
        5000,
        (i) => createTestTask(
          id: 't-$i',
          dueDate: i.isEven ? DateTime(2020, 1, 1) : DateTime(2099, 1, 1),
          status: i % 3 == 0 ? TaskStatus.done : TaskStatus.todo,
        ),
      );
      final state = DashboardState(myTasks: tasks);

      final sw = Stopwatch()..start();
      final overdue = state.overdueTasks;
      sw.stop();
      expect(overdue, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(20));
    });
  });

  group('PERF-EXT-006: Task copyWith performance', () {
    test('1000 copyWith operations under 20ms', () {
      final task = createTestTask();
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        task.copyWith(title: 'Updated $i');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(20));
    });
  });

  group('PERF-EXT-007: Search with special characters', () {
    test('Search with regex-like chars does not crash', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: '1', title: 'Task (with) [brackets]'),
          createTestTask(id: '2', title: 'Normal task'),
        ],
        searchQuery: '(with)',
      );
      // Should filter without crashing
      expect(state.filteredTasks.length, 1);
    });

    test('Search with empty query returns all', () {
      final tasks = List.generate(100, (i) => createTestTask(id: 't-$i'));
      final state = TaskState(tasks: tasks, searchQuery: '');
      expect(state.filteredTasks.length, 100);
    });
  });

  group('PERF-EXT-008: StatusBadge rendering performance', () {
    testWidgets('Renders 20 StatusBadges', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: ListView.builder(
            itemCount: 20,
            itemBuilder: (_, i) => StatusBadge(
              status: TaskStatus.values[i % TaskStatus.values.length],
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(StatusBadge), findsWidgets);
    });
  });

  group('PERF-EXT-009: Analytics model parsing performance', () {
    test('Parse complex analytics under 10ms', () {
      final json = {
        'completionRate': 75,
        'totalTasks': 1000,
        'completedTasks': 750,
        'overdueTasks': 50,
        'avgCompletionDays': 4.2,
        'tasksByPriority': List.generate(4, (i) => {
          'priority': ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'][i],
          'count': 250,
        }),
        'tasksByStatus': List.generate(5, (i) => {
          'status': ['TODO', 'IN_PROGRESS', 'UNDER_REVIEW', 'DONE', 'ARCHIVED'][i],
          'count': 200,
        }),
        'teamWorkload': List.generate(20, (i) => {
          'userId': 'u-$i',
          'name': 'User $i',
          'total': 50,
          'done': 25,
          'inProgress': 15,
        }),
        'weeklyStats': List.generate(12, (i) => {
          'weekStart': '2024-0${(i % 9) + 1}-01',
          'weekEnd': '2024-0${(i % 9) + 1}-07',
          'created': 20,
          'completed': 15,
        }),
      };

      final sw = Stopwatch()..start();
      final analytics = Analytics.fromJson(json);
      sw.stop();
      expect(analytics.teamWorkload.length, 20);
      expect(analytics.weeklyStats.length, 12);
      expect(sw.elapsedMilliseconds, lessThan(10));
    });
  });

  group('PERF-EXT-010: TaskState taskCountByStatus on large dataset', () {
    test('5000 tasks counted by status under 20ms', () {
      final tasks = List.generate(
        5000,
        (i) => createTestTask(
          id: 't-$i',
          status: TaskStatus.values[i % TaskStatus.values.length],
        ),
      );
      final state = TaskState(tasks: tasks);

      final sw = Stopwatch()..start();
      final counts = state.taskCountByStatus;
      sw.stop();
      expect(counts.values.reduce((a, b) => a + b), 5000);
      expect(sw.elapsedMilliseconds, lessThan(20));
    });
  });
}
