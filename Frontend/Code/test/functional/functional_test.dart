// =============================================================================
// Category 5: Functional Tests
// Tests: Model serialization/deserialization, state management logic,
//        viewmodel state transitions, filter/search logic, data integrity
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/user.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/analytics.dart';
import 'package:task_management_app/data/models/dashboard.dart';
import 'package:task_management_app/data/models/search_result.dart';
import 'package:task_management_app/data/models/auth_response.dart';
import 'package:task_management_app/data/api/api_config.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/dashboard_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('FUNC-001: Task model serialization', () {
    test('fromJson round-trip', () {
      final json = {
        'id': 't-1',
        'projectId': 'p-1',
        'title': 'Test Task',
        'description': 'A desc',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'dueDate': '2024-06-15T00:00:00.000Z',
        'creatorId': 'u-1',
        'assigneeIds': ['u-1', 'u-2'],
        'labelIds': ['l-1'],
        'subTasks': [
          {
            'id': 's-1',
            'taskId': 't-1',
            'title': 'Sub 1',
            'isDone': true,
            'createdAt': '2024-01-01T00:00:00.000Z',
          }
        ],
        'position': 3,
        'attachments': [],
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final task = Task.fromJson(json);
      expect(task.id, 't-1');
      expect(task.status, TaskStatus.inProgress);
      expect(task.priority, TaskPriority.high);
      expect(task.assigneeIds.length, 2);
      expect(task.subTasks.length, 1);
      expect(task.subTasks.first.isDone, true);
    });

    test('toJson includes expected fields', () {
      final task = createTestTask();
      final json = task.toJson();
      expect(json.containsKey('title'), true);
      expect(json.containsKey('status'), true);
      expect(json.containsKey('priority'), true);
    });

    test('copyWith preserves non-changed fields', () {
      final task = createTestTask(title: 'Original', description: 'Desc');
      final updated = task.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.description, 'Desc');
      expect(updated.id, task.id);
    });

    test('completedSubTaskCount correct', () {
      final task = createTestTask(subTasks: [
        createTestSubTask(id: 's1', isDone: true),
        createTestSubTask(id: 's2', isDone: false),
        createTestSubTask(id: 's3', isDone: true),
      ]);
      expect(task.completedSubTaskCount, 2);
    });
  });

  group('FUNC-002: Project model', () {
    test('fromJson with camelCase', () {
      final project = Project.fromJson({
        'id': 'p-1',
        'name': 'My Project',
        'description': 'Desc',
        'ownerId': 'u-1',
        'isArchived': true,
        'memberCount': 5,
        'taskCount': 10,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(project.name, 'My Project');
      expect(project.isArchived, true);
      expect(project.memberCount, 5);
    });

    test('fromJson with snake_case', () {
      final project = Project.fromJson({
        'id': 'p-1',
        'name': 'Project',
        'owner_id': 'u-1',
        'is_archived': false,
        'member_count': 2,
        'task_count': 0,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      });
      expect(project.ownerId, 'u-1');
      expect(project.isArchived, false);
    });
  });

  group('FUNC-003: User model', () {
    test('fromJson and toJson', () {
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'test@test.com',
        'name': 'Test',
        'bio': 'Hello',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.email, 'test@test.com');
      expect(user.bio, 'Hello');

      final json = user.toJson();
      expect(json['id'], 'u-1');
      expect(json['email'], 'test@test.com');
    });

    test('copyWith', () {
      final user = createTestUser(name: 'Old');
      final updated = user.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.email, user.email);
    });
  });

  group('FUNC-004: AuthResponse model', () {
    test('fromJson parses correctly', () {
      final response = AuthResponse.fromJson({
        'user': {
          'id': 'u-1',
          'email': 'test@test.com',
          'name': 'Test',
          'createdAt': '2024-01-01T00:00:00Z',
        },
        'tokens': {
          'accessToken': 'at-123',
          'refreshToken': 'rt-456',
        },
      });
      expect(response.user.id, 'u-1');
      expect(response.tokens.accessToken, 'at-123');
      expect(response.tokens.refreshToken, 'rt-456');
    });
  });

  group('FUNC-005: TaskState', () {
    test('getTasksByStatus', () {
      final state = TaskState(tasks: [
        createTestTask(id: '1', status: TaskStatus.todo),
        createTestTask(id: '2', status: TaskStatus.done),
        createTestTask(id: '3', status: TaskStatus.todo),
      ]);
      expect(state.getTasksByStatus(TaskStatus.todo).length, 2);
      expect(state.getTasksByStatus(TaskStatus.done).length, 1);
    });

    test('taskCountByStatus', () {
      final state = TaskState(tasks: [
        createTestTask(id: '1', status: TaskStatus.todo),
        createTestTask(id: '2', status: TaskStatus.inProgress),
      ]);
      final counts = state.taskCountByStatus;
      expect(counts[TaskStatus.todo], 1);
      expect(counts[TaskStatus.inProgress], 1);
      expect(counts[TaskStatus.done], 0);
    });

    test('copyWith clears filters', () {
      final state = TaskState(
        tasks: [createTestTask()],
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
      );
      final cleared = state.copyWith(
        clearStatusFilter: true,
        clearPriorityFilter: true,
      );
      expect(cleared.statusFilter, isNull);
      expect(cleared.priorityFilter, isNull);
    });
  });

  group('FUNC-006: AuthState', () {
    test('Default state', () {
      const state = AuthState();
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('copyWith clearError', () {
      const state = AuthState(error: 'Something wrong');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });

  group('FUNC-007: DashboardState', () {
    test('overdueTasks computed property', () {
      final state = DashboardState(myTasks: [
        createTestTask(id: '1', dueDate: DateTime(2020, 1, 1), status: TaskStatus.todo),
        createTestTask(id: '2', dueDate: DateTime(2099, 1, 1), status: TaskStatus.todo),
      ]);
      expect(state.overdueTasks.length, 1);
      expect(state.overdueTasks.first.id, '1');
    });
  });

  group('FUNC-008: ApiConfig', () {
    test('Dev environment URL', () {
      ApiConfig.setEnvironment(Environment.dev);
      expect(ApiConfig.baseUrl, 'https://task-management-api-brown.vercel.app/api');
      expect(ApiConfig.isProduction, false);
    });

    test('Production environment URL', () {
      ApiConfig.setEnvironment(Environment.production);
      expect(ApiConfig.baseUrl, 'https://task-management-api-brown.vercel.app/api');
      expect(ApiConfig.isProduction, true);
    });
  });

  group('FUNC-009: SearchResult model', () {
    test('fromJson with data', () {
      final result = SearchResult.fromJson({
        'tasks': [
          {
            'id': 't-1',
            'projectId': 'p-1',
            'title': 'Task',
            'status': 'TODO',
            'priority': 'MEDIUM',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          }
        ],
        'projects': [],
      });
      expect(result.tasks.length, 1);
      expect(result.projects, isEmpty);
    });

    test('toJson', () {
      final result = SearchResult(tasks: [], projects: []);
      final json = result.toJson();
      expect(json['tasks'], isEmpty);
      expect(json['projects'], isEmpty);
    });
  });

  group('FUNC-010: NotificationType and ProjectRole', () {
    test('NotificationType fromString', () {
      expect(NotificationType.fromString('TASK_ASSIGNED'),
          NotificationType.taskAssigned);
      expect(
          NotificationType.fromString('DUE_SOON'), NotificationType.dueSoon);
      expect(NotificationType.fromString('COMMENT_ADDED'),
          NotificationType.commentAdded);
    });

    test('ProjectRole apiValue', () {
      expect(ProjectRole.owner.apiValue, 'OWNER');
      expect(ProjectRole.admin.apiValue, 'ADMIN');
      expect(ProjectRole.member.apiValue, 'MEMBER');
      expect(ProjectRole.viewer.apiValue, 'VIEWER');
    });

    test('ProjectRole displayName', () {
      expect(ProjectRole.owner.displayName, 'Owner');
      expect(ProjectRole.viewer.displayName, 'Viewer');
    });
  });
}
