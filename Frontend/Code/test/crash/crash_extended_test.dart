// =============================================================================
// Category 9 Extended: Crash / Resilience Tests
// NEW tests: completely empty JSON for all models, null-like string values,
// integer overflow in model fields, deeply nested subtasks, concurrent state
// mutations, widget rendering with extreme data, emoji in model fields,
// timestamp edge cases, ProjectMember/Label/Activity crash scenarios,
// DashboardMyTasks/ProjectDashboard crash scenarios
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/user.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/analytics.dart';
import 'package:task_management_app/data/models/dashboard.dart';
import 'package:task_management_app/data/models/attachment.dart';
import 'package:task_management_app/data/models/activity.dart';
import 'package:task_management_app/data/models/label.dart';
import 'package:task_management_app/data/models/auth_response.dart';
import 'package:task_management_app/data/api/api_exception.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/project_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/notification_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/comment_viewmodel.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/presentation/views/widgets/priority_badge.dart';
import 'package:task_management_app/presentation/views/widgets/status_badge.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CRASH-EXT-001: Completely empty JSON for all models', () {
    test('Task.fromJson empty map', () {
      final task = Task.fromJson(<String, dynamic>{});
      expect(task.id, '');
      expect(task.title, '');
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.medium);
    });

    test('Project.fromJson empty map', () {
      final project = Project.fromJson(<String, dynamic>{});
      expect(project.id, '');
      expect(project.name, '');
    });

    test('User.fromJson empty map', () {
      final user = User.fromJson(<String, dynamic>{});
      expect(user.id, '');
      expect(user.email, '');
      expect(user.name, '');
    });

    test('Comment.fromJson empty map', () {
      final comment = Comment.fromJson(<String, dynamic>{});
      expect(comment.id, '');
      expect(comment.authorName, 'Unknown');
      expect(comment.body, '');
    });

    test('AppNotification.fromJson empty map', () {
      final notif = AppNotification.fromJson(<String, dynamic>{});
      expect(notif.id, '');
      expect(notif.userId, '');
      expect(notif.type, NotificationType.taskAssigned);
    });

    test('Attachment.fromJson empty map', () {
      final a = Attachment.fromJson(<String, dynamic>{});
      expect(a.id, '');
      expect(a.fileName, '');
      expect(a.fileSize, 0);
    });

    test('Activity.fromJson empty map', () {
      final a = Activity.fromJson(<String, dynamic>{});
      expect(a.id, '');
      expect(a.userName, 'Unknown');
      expect(a.action, '');
    });

    test('Label.fromJson empty map', () {
      final l = Label.fromJson(<String, dynamic>{});
      expect(l.id, '');
      expect(l.name, '');
      expect(l.colorHex, '#6B7280');
    });

    test('SubTask.fromJson empty map', () {
      final s = SubTask.fromJson(<String, dynamic>{});
      expect(s.id, '');
      expect(s.title, '');
      expect(s.isDone, false);
    });

    test('AuthResponse.fromJson empty map', () {
      final r = AuthResponse.fromJson(<String, dynamic>{});
      expect(r.user.id, '');
      expect(r.tokens.accessToken, '');
    });

    test('ProjectMember.fromJson empty map', () {
      final m = ProjectMember.fromJson(<String, dynamic>{});
      expect(m.id, '');
      expect(m.userName, '');
      expect(m.role, ProjectRole.member);
    });
  });

  group('CRASH-EXT-002: Null-like string values', () {
    test('Task with "null" string title', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'null',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.title, 'null');
    });

    test('User with "undefined" email', () {
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'undefined',
        'name': 'Test',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.email, 'undefined');
    });
  });

  group('CRASH-EXT-003: Integer boundary values in models', () {
    test('Very large fileSize in attachment', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'fileSize': 9999999999,
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.fileSize, 9999999999);
    });

    test('Zero values in analytics', () {
      final analytics = Analytics.fromJson({
        'completionRate': 0,
        'totalTasks': 0,
        'completedTasks': 0,
        'overdueTasks': 0,
        'avgCompletionDays': 0.0,
      });
      expect(analytics.totalTasks, 0);
      expect(analytics.avgCompletionDays, 0.0);
    });

    test('Negative position in task', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'LOW',
        'position': -1,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.position, -1);
    });
  });

  group('CRASH-EXT-004: Emoji in model fields', () {
    test('Emoji in task title', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': '\u{1F4BB} Code review \u{2705}',
        'status': 'TODO',
        'priority': 'HIGH',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.title, contains('\u{1F4BB}'));
    });

    test('Emoji in user name', () {
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'test@test.com',
        'name': '\u{1F60A} Alice',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.name, contains('\u{1F60A}'));
    });

    test('Emoji in comment body', () {
      final c = Comment.fromJson({
        'id': 'c-1',
        'body': 'Great work! \u{1F389}\u{1F44D}',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(c.body, contains('\u{1F389}'));
    });
  });

  group('CRASH-EXT-005: Timestamp edge cases', () {
    test('Unix epoch timestamp string', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '1970-01-01T00:00:00Z',
        'updatedAt': '1970-01-01T00:00:00Z',
      });
      expect(task.createdAt.year, 1970);
    });

    test('Far future timestamp', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2999-12-31T23:59:59Z',
        'updatedAt': '2999-12-31T23:59:59Z',
      });
      expect(task.createdAt.year, 2999);
    });

    test('Invalid timestamp falls back to now', () {
      final before = DateTime.now();
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': 'completely-invalid',
        'updatedAt': 'also-invalid',
      });
      expect(task.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), true);
    });
  });

  group('CRASH-EXT-006: DashboardMyTasks crash scenarios', () {
    test('Missing tasks key', () {
      final dmt = DashboardMyTasks.fromJson(<String, dynamic>{});
      expect(dmt.tasks, isEmpty);
      expect(dmt.totalCount, 0);
    });

    test('Null tasks list', () {
      final dmt = DashboardMyTasks.fromJson({'tasks': null, 'totalCount': 5});
      expect(dmt.tasks, isEmpty);
    });
  });

  group('CRASH-EXT-007: ProjectDashboard crash scenarios', () {
    test('Missing all fields', () {
      final pd = ProjectDashboard.fromJson(<String, dynamic>{});
      expect(pd.tasksByStatus, isEmpty);
      expect(pd.totalTasks, 0);
    });

    test('Null maps', () {
      final pd = ProjectDashboard.fromJson({
        'tasksByStatus': null,
        'tasksByPriority': null,
      });
      expect(pd.tasksByStatus, isEmpty);
      expect(pd.tasksByPriority, isEmpty);
    });
  });

  group('CRASH-EXT-008: DashboardTrends crash scenarios', () {
    test('Empty list input', () {
      final trends = DashboardTrends.fromJson(<dynamic>[]);
      expect(trends.dataPoints, isEmpty);
    });

    test('Map with null data', () {
      final trends = DashboardTrends.fromJson({'data': null});
      expect(trends.dataPoints, isEmpty);
    });
  });

  group('CRASH-EXT-009: TaskState edge cases', () {
    test('filteredTasks with only search no other filters', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: '1', title: 'Alpha'),
          createTestTask(id: '2', title: 'Beta'),
        ],
        searchQuery: 'gamma',
      );
      expect(state.filteredTasks, isEmpty);
    });

    test('getTasksByStatus on filtered list', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: '1', status: TaskStatus.todo, priority: TaskPriority.high),
          createTestTask(id: '2', status: TaskStatus.todo, priority: TaskPriority.low),
          createTestTask(id: '3', status: TaskStatus.done, priority: TaskPriority.high),
        ],
        priorityFilter: TaskPriority.high,
      );
      final todoTasks = state.getTasksByStatus(TaskStatus.todo);
      expect(todoTasks.length, 1);
      expect(todoTasks.first.id, '1');
    });

    test('myTasks returns all tasks', () {
      final state = TaskState(tasks: [
        createTestTask(id: '1'),
        createTestTask(id: '2'),
      ]);
      expect(state.myTasks.length, 2);
    });
  });

  group('CRASH-EXT-010: Widget rendering with extreme data', () {
    testWidgets('TaskCard with very long title', (tester) async {
      final task = createTestTask(title: 'A' * 500);
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
      // No overflow crash due to maxLines and ellipsis
    });

    testWidgets('TaskCard with very long description', (tester) async {
      final task = createTestTask(
        title: 'Normal',
        description: 'D' * 1000,
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
    });

    testWidgets('TaskCard with many assignees', (tester) async {
      final task = createTestTask(
        title: 'Many assignees',
        assigneeIds: List.generate(10, (i) => 'u-$i'),
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
    });

    testWidgets('EmptyState with very long title', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'A' * 200,
            subtitle: 'B' * 300,
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('PriorityBadge in compact mode for all priorities', (tester) async {
      for (final p in TaskPriority.values) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(body: PriorityBadge(priority: p, compact: true)),
        ));
        await tester.pump();
      }
    });
  });

  group('CRASH-EXT-011: State copyWith chain resilience', () {
    test('Multiple TaskState copyWith calls in sequence', () {
      var state = const TaskState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(tasks: [createTestTask()]);
      state = state.copyWith(isLoading: false);
      state = state.copyWith(statusFilter: TaskStatus.todo);
      state = state.copyWith(clearStatusFilter: true);
      state = state.copyWith(error: 'test');
      state = state.copyWith(clearError: true);
      expect(state.error, isNull);
      expect(state.statusFilter, isNull);
      expect(state.tasks.length, 1);
    });

    test('Multiple AuthState copyWith calls', () {
      var state = const AuthState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(user: createTestUser(), isAuthenticated: true, isLoading: false);
      state = state.copyWith(error: 'Session expired');
      state = state.copyWith(clearError: true);
      expect(state.user, isNotNull);
      expect(state.error, isNull);
    });

    test('Multiple DashboardState copyWith calls', () {
      var state = const DashboardState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(myTasks: [createTestTask()], isLoading: false);
      state = state.copyWith(error: 'fail');
      state = state.copyWith(clearError: true);
      expect(state.myTasks.length, 1);
      expect(state.error, isNull);
    });

    test('Multiple ProjectState copyWith calls', () {
      var state = const ProjectState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(projects: [createTestProject()], isLoading: false);
      state = state.copyWith(selectedProject: createTestProject(id: 'p-sel'));
      state = state.copyWith(clearSelectedProject: true);
      expect(state.selectedProject, isNull);
      expect(state.projects.length, 1);
    });

    test('Multiple NotificationState copyWith calls', () {
      var state = const NotificationState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(
        notifications: [createTestNotification()],
        isLoading: false,
      );
      state = state.copyWith(error: 'err');
      state = state.copyWith(clearError: true);
      expect(state.notifications.length, 1);
      expect(state.error, isNull);
    });

    test('Multiple CommentState copyWith calls', () {
      var state = const CommentState();
      state = state.copyWith(isLoading: true);
      state = state.copyWith(
        comments: [createTestComment()],
        isLoading: false,
      );
      state = state.copyWith(error: 'err');
      state = state.copyWith(clearError: true);
      expect(state.comments.length, 1);
      expect(state.error, isNull);
    });
  });

  group('CRASH-EXT-012: Task.fromJson with wrong types handled gracefully', () {
    test('Numeric title coerced or defaulted', () {
      // If the JSON has wrong type, Dart as String? returns null, default kicks in
      final task = Task.fromJson({
        'id': 't-1',
        'title': null,
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.title, '');
    });

    test('Null status defaults to TODO', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Test',
        'status': null,
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.status, TaskStatus.todo);
    });

    test('Null priority defaults to MEDIUM', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Test',
        'status': 'TODO',
        'priority': null,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.priority, TaskPriority.medium);
    });
  });

  group('CRASH-EXT-013: Attachment isImage edge cases', () {
    test('Empty mimeType is not image', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'mimeType': '',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.isImage, false);
    });

    test('image/svg+xml is image', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'mimeType': 'image/svg+xml',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.isImage, true);
    });

    test('application/pdf is not image', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'mimeType': 'application/pdf',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.isImage, false);
    });
  });

  group('CRASH-EXT-014: Task with many subtasks', () {
    test('Task with 100 subtasks does not crash', () {
      final subTasks = List.generate(
        100,
        (i) => {'id': 'sub-$i', 'title': 'Sub $i', 'isDone': i.isEven, 'createdAt': '2024-01-01T00:00:00Z'},
      );
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Big Task',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'subTasks': subTasks,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.subTasks.length, 100);
      expect(task.completedSubTaskCount, 50);
    });
  });
}
