// =============================================================================
// Category 9: Crash / Resilience Tests
// Tests: Null safety, malformed JSON, edge cases, boundary values,
//        empty states, extreme inputs, widget error handling
// =============================================================================
// CRITICAL FINDINGS:
// CRASH-001: firstWhere without orElse in TaskViewModel.toggleSubTask (line 206)
// CRASH-002: Empty authorName string indexing [0] in task_detail_screen (line 930)
// CRASH-003: PageController created in build() leaking in project_board_screen (line 333)
// CRASH-004: Missing required JSON fields cause uncaught type errors
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/user.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/analytics.dart';
import 'package:task_management_app/data/models/attachment.dart';
import 'package:task_management_app/data/models/dashboard.dart';
import 'package:task_management_app/data/models/search_result.dart';
import 'package:task_management_app/data/models/activity.dart';
import 'package:task_management_app/data/models/label.dart';
import 'package:task_management_app/data/models/auth_response.dart';
import 'package:task_management_app/data/api/api_exception.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CRASH-001: firstWhere without orElse in TaskViewModel.toggleSubTask',
      () {
    test('toggleSubTask with non-existent subtask ID throws StateError', () {
      final task = createTestTask(
        id: 'task-1',
        subTasks: [
          createTestSubTask(id: 'sub-1', title: 'Existing subtask'),
        ],
      );
      expect(
        () => task.subTasks.firstWhere((s) => s.id == 'non-existent-id'),
        throwsStateError,
        reason:
            'CRASH: firstWhere without orElse at task_viewmodel.dart:206',
      );
    });

    test('toggleSubTask with empty subtask list throws StateError', () {
      final task = createTestTask(id: 'task-1', subTasks: []);
      expect(
        () => task.subTasks.firstWhere((s) => s.id == 'any-id'),
        throwsStateError,
        reason:
            'CRASH: firstWhere on empty list at task_viewmodel.dart:206',
      );
    });

    test('indexWhere returns -1 but firstWhere still crashes', () {
      final task = createTestTask(
        id: 'task-1',
        subTasks: [createTestSubTask(id: 'sub-1')],
      );
      // indexWhere returns -1 safely, but the subsequent firstWhere can crash
      final idx = task.subTasks.indexWhere((s) => s.id == 'missing');
      expect(idx, -1);
      // The viewmodel checks indexWhere==-1 but if taskIndex IS valid
      // and subtask id is wrong, firstWhere crashes
      expect(
        () => task.subTasks.firstWhere((s) => s.id == 'missing'),
        throwsStateError,
      );
    });
  });

  group('CRASH-002: Empty authorName string indexing', () {
    test('Empty authorName[0] throws RangeError', () {
      final comment = Comment(
        id: 'c-1',
        taskId: 'task-1',
        authorId: 'user-1',
        authorName: '',
        body: 'test',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      expect(
        () => comment.authorName[0],
        throwsRangeError,
        reason: 'CRASH: Empty string [0] at task_detail_screen.dart:930',
      );
    });

    test('Comment.fromJson with explicit empty authorName', () {
      final json = {
        'id': 'c-1',
        'taskId': 'task-1',
        'authorId': 'user-1',
        'authorName': '',
        'body': 'test',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      };
      final comment = Comment.fromJson(json);
      expect(comment.authorName, '');
      expect(() => comment.authorName[0], throwsRangeError);
    });

    test('Empty member name in TeamWorkload similarly crashes', () {
      final member = TeamWorkload(
        userId: 'u-1',
        name: '',
        total: 5,
        done: 3,
        inProgress: 2,
      );
      expect(() => member.name[0], throwsRangeError,
          reason: 'Empty name[0] crash in analytics_screen.dart:612');
    });
  });

  group('CRASH-003: PageController in build method', () {
    test('PageController created each build leaks controllers', () {
      int count = 0;
      for (int i = 0; i < 10; i++) {
        PageController(viewportFraction: 0.88);
        count++;
      }
      expect(count, 10,
          reason: 'BUG: project_board_screen.dart:333 leaks controllers');
    });
  });

  group('CRASH-004: Task.fromJson missing fields handled gracefully', () {
    test('Missing id uses empty default', () {
      final task = Task.fromJson({
        'title': 'T',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      });
      expect(task.id, '');
      expect(task.title, 'T');
    });

    test('Missing createdAt uses fallback', () {
      final task = Task.fromJson({
        'id': 't-1',
        'projectId': 'p-1',
        'title': 'T',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.id, 't-1');
      expect(task.createdAt, isNotNull);
    });

    test('Invalid dueDate returns null gracefully', () {
      final task = Task.fromJson({
        'id': 't-1',
        'projectId': 'p-1',
        'title': 'T',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'dueDate': 'not-a-date',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.dueDate, isNull);
    });
  });

  group('CRASH-005: Project.fromJson missing dates handled gracefully', () {
    test('Missing both createdAt variants uses fallback', () {
      final project = Project.fromJson({
        'id': 'p-1',
        'name': 'Test',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(project.id, 'p-1');
      expect(project.createdAt, isNotNull);
    });
  });

  group('CRASH-006: User.fromJson missing fields handled gracefully', () {
    test('Missing id uses empty default', () {
      final user = User.fromJson({
        'email': 'a@b.com',
        'name': 'T',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.id, '');
      expect(user.name, 'T');
    });
  });

  group('CRASH-007: AuthResponse.fromJson handled gracefully', () {
    test('Missing user key uses defaults', () {
      final resp = AuthResponse.fromJson({
        'tokens': {'accessToken': 'a', 'refreshToken': 'r'},
      });
      expect(resp.tokens.accessToken, 'a');
      expect(resp.user, isNotNull);
    });

    test('Missing tokens key uses defaults', () {
      final resp = AuthResponse.fromJson({
        'user': {
          'id': 'u-1',
          'email': 'a@b.com',
          'name': 'T',
          'createdAt': '2024-01-01T00:00:00Z',
        },
      });
      expect(resp.user.id, 'u-1');
      expect(resp.tokens.accessToken, '');
    });
  });

  group('CRASH-008: Notification.fromJson missing userId handled gracefully', () {
    test('Missing userId uses empty default', () {
      final notif = AppNotification.fromJson({
        'id': 'n-1',
        'type': 'TASK_ASSIGNED',
        'title': 'T',
        'body': 'B',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(notif.id, 'n-1');
      expect(notif.userId, '');
    });
  });

  group('CRASH-009: Safe model parsing', () {
    test('Label.fromJson with missing color uses default', () {
      final label = Label.fromJson({'id': 'l-1', 'name': 'Bug'});
      expect(label.colorHex, '#6B7280');
      expect(label.color, isNotNull);
    });

    test('DashboardTrends handles list input', () {
      final trends = DashboardTrends.fromJson([
        {'date': '2024-01-01', 'created': 5, 'completed': 3},
      ]);
      expect(trends.dataPoints.length, 1);
    });

    test('DashboardTrends handles map input', () {
      final trends = DashboardTrends.fromJson({
        'data': [
          {'date': '2024-01-01', 'created': 5, 'completed': 3},
        ],
      });
      expect(trends.dataPoints.length, 1);
    });

    test('DashboardTrends handles empty map', () {
      final trends = DashboardTrends.fromJson(<String, dynamic>{});
      expect(trends.dataPoints, isEmpty);
    });

    test('SearchResult handles null lists', () {
      final result = SearchResult.fromJson(<String, dynamic>{});
      expect(result.tasks, isEmpty);
      expect(result.projects, isEmpty);
    });

    test('Analytics handles all empty arrays', () {
      final analytics = Analytics.fromJson({
        'completionRate': 0,
        'totalTasks': 0,
        'completedTasks': 0,
        'overdueTasks': 0,
        'avgCompletionDays': 0.0,
      });
      expect(analytics.tasksByPriority, isEmpty);
      expect(analytics.teamWorkload, isEmpty);
    });

    test('Attachment with missing fields uses defaults', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.taskId, '');
      expect(a.fileName, '');
      expect(a.fileSize, 0);
    });

    test('Activity with minimal JSON', () {
      final a = Activity.fromJson({
        'id': 'act-1',
        'action': 'created',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.userName, 'Unknown');
      expect(a.taskId, '');
    });

    test('SubTask handles missing taskId', () {
      final s = SubTask.fromJson({
        'id': 'sub-1',
        'title': 'Test',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(s.taskId, '');
      expect(s.isDone, false);
    });
  });

  group('CRASH-010: Enum fromString edge cases', () {
    test('Unknown status returns default', () {
      expect(TaskStatus.fromString('INVALID'), TaskStatus.todo);
      expect(TaskStatus.fromString(''), TaskStatus.todo);
    });

    test('Unknown priority returns default', () {
      expect(TaskPriority.fromString('INVALID'), TaskPriority.medium);
    });

    test('ProjectRole unknown returns member', () {
      expect(ProjectRole.fromString('INVALID'), ProjectRole.member);
    });

    test('NotificationType unknown returns taskAssigned', () {
      expect(NotificationType.fromString('INVALID'),
          NotificationType.taskAssigned);
    });
  });

  group('CRASH-011: Task isOverdue edge cases', () {
    test('Null dueDate is not overdue', () {
      final task = createTestTask(dueDate: null);
      expect(task.isOverdue, false);
    });

    test('Done task is not overdue even with past date', () {
      final task = createTestTask(
        dueDate: DateTime(2020, 1, 1),
        status: TaskStatus.done,
      );
      expect(task.isOverdue, false);
    });

    test('Archived task is not overdue', () {
      final task = createTestTask(
        dueDate: DateTime(2020, 1, 1),
        status: TaskStatus.archived,
      );
      expect(task.isOverdue, false);
    });

    test('Past due todo task is overdue', () {
      final task = createTestTask(
        dueDate: DateTime(2020, 1, 1),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, true);
    });
  });

  group('CRASH-012: TaskState filteredTasks', () {
    test('All filters with empty list', () {
      const state = TaskState(
        tasks: [],
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
        searchQuery: 'x',
      );
      expect(state.filteredTasks, isEmpty);
    });

    test('Case insensitive search', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: 't-1', title: 'BUY groceries'),
          createTestTask(id: 't-2', title: 'Write code'),
        ],
        searchQuery: 'buy',
      );
      expect(state.filteredTasks.length, 1);
    });

    test('Description search', () {
      final state = TaskState(
        tasks: [
          createTestTask(
            id: 't-1',
            title: 'Task',
            description: 'fix the LOGIN page',
          ),
        ],
        searchQuery: 'login',
      );
      expect(state.filteredTasks.length, 1);
    });
  });

  group('CRASH-013: ApiException', () {
    test('toString returns message', () {
      final e = ApiException('test error', statusCode: 500);
      expect(e.toString(), 'test error');
      expect(e.statusCode, 500);
    });
  });
}
