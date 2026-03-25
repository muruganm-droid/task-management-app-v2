// =============================================================================
// Category 5 Extended: Functional Tests
// NEW tests: model toJson completeness, SubTask model, Comment model,
// Attachment model, Label model, Activity model, ProjectMember model,
// WeeklyStats model, PriorityCount/StatusCount models,
// DashboardMyTasks/ProjectDashboard models, Task copyWith all fields,
// TrendDataPoint model, enum display names
// =============================================================================

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
import '../helpers/test_helpers.dart';

void main() {
  group('FUNC-EXT-001: SubTask model full coverage', () {
    test('fromJson with snake_case', () {
      final sub = SubTask.fromJson({
        'id': 's-1',
        'task_id': 't-1',
        'title': 'Sub A',
        'is_done': true,
        'created_at': '2024-01-01T00:00:00Z',
      });
      expect(sub.taskId, 't-1');
      expect(sub.isDone, true);
    });

    test('toJson output', () {
      final sub = createTestSubTask(title: 'Write test', isDone: true);
      final json = sub.toJson();
      expect(json['title'], 'Write test');
      expect(json['isDone'], true);
    });

    test('copyWith title', () {
      final sub = createTestSubTask(title: 'Old');
      final updated = sub.copyWith(title: 'New');
      expect(updated.title, 'New');
      expect(updated.isDone, sub.isDone);
    });

    test('copyWith isDone', () {
      final sub = createTestSubTask(isDone: false);
      final toggled = sub.copyWith(isDone: true);
      expect(toggled.isDone, true);
    });
  });

  group('FUNC-EXT-002: Comment model', () {
    test('fromJson with snake_case', () {
      final c = Comment.fromJson({
        'id': 'c-1',
        'task_id': 't-1',
        'author_id': 'u-1',
        'author_name': 'John',
        'body': 'Hello',
        'is_edited': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
      });
      expect(c.taskId, 't-1');
      expect(c.authorName, 'John');
      expect(c.isEdited, true);
    });

    test('fromJson missing authorName defaults to Unknown', () {
      final c = Comment.fromJson({
        'id': 'c-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(c.authorName, 'Unknown');
    });

    test('toJson returns body', () {
      final c = createTestComment(body: 'Test body');
      final json = c.toJson();
      expect(json['body'], 'Test body');
      expect(json.length, 1);
    });

    test('authorAvatar can be null', () {
      final c = createTestComment();
      expect(c.authorAvatar, isNull);
    });
  });

  group('FUNC-EXT-003: Attachment model', () {
    test('fromJson with camelCase', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'taskId': 't-1',
        'uploaderId': 'u-1',
        'fileName': 'doc.pdf',
        'fileUrl': 'https://example.com/doc.pdf',
        'mimeType': 'application/pdf',
        'fileSize': 1024,
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.fileName, 'doc.pdf');
      expect(a.fileSize, 1024);
      expect(a.isImage, false);
    });

    test('isImage returns true for image mimeType', () {
      final a = Attachment.fromJson({
        'id': 'a-2',
        'mimeType': 'image/png',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.isImage, true);
    });

    test('toJson round trip', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'taskId': 't-1',
        'uploaderId': 'u-1',
        'fileName': 'test.jpg',
        'fileUrl': 'https://x.com/test.jpg',
        'mimeType': 'image/jpeg',
        'fileSize': 2048,
        'createdAt': '2024-01-01T00:00:00Z',
      });
      final json = a.toJson();
      expect(json['id'], 'a-1');
      expect(json['fileName'], 'test.jpg');
      expect(json['fileSize'], 2048);
    });

    test('fromJson with snake_case', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'task_id': 't-1',
        'uploader_id': 'u-1',
        'file_name': 'report.xlsx',
        'file_url': 'https://x.com/report.xlsx',
        'mime_type': 'application/xlsx',
        'file_size': 4096,
        'created_at': '2024-01-01T00:00:00Z',
      });
      expect(a.taskId, 't-1');
      expect(a.uploaderId, 'u-1');
      expect(a.fileName, 'report.xlsx');
    });
  });

  group('FUNC-EXT-004: Label model', () {
    test('fromJson with color', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'projectId': 'p-1',
        'name': 'Bug',
        'color': '#FF0000',
      });
      expect(l.name, 'Bug');
      expect(l.colorHex, '#FF0000');
      expect(l.color, isNotNull);
    });

    test('toJson', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'name': 'Feature',
        'color': '#00FF00',
      });
      final json = l.toJson();
      expect(json['name'], 'Feature');
      expect(json['color'], '#00FF00');
    });

    test('Color parsing from hex', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'name': 'Test',
        'color': '#6366F1',
      });
      // Should parse to a valid color (0xFF6366F1)
      expect(l.color.toARGB32(), 0xFF6366F1);
    });

    test('fromJson with snake_case projectId', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'project_id': 'p-2',
        'name': 'Label',
      });
      expect(l.projectId, 'p-2');
    });
  });

  group('FUNC-EXT-005: Activity model', () {
    test('fromJson full data', () {
      final a = Activity.fromJson({
        'id': 'act-1',
        'taskId': 't-1',
        'userId': 'u-1',
        'userName': 'Alice',
        'action': 'updated',
        'details': 'Changed status',
        'createdAt': '2024-06-01T00:00:00Z',
      });
      expect(a.userName, 'Alice');
      expect(a.action, 'updated');
      expect(a.details, 'Changed status');
    });

    test('fromJson with snake_case', () {
      final a = Activity.fromJson({
        'id': 'act-1',
        'task_id': 't-1',
        'user_id': 'u-1',
        'user_name': 'Bob',
        'action': 'created',
        'created_at': '2024-01-01T00:00:00Z',
      });
      expect(a.taskId, 't-1');
      expect(a.userId, 'u-1');
      expect(a.userName, 'Bob');
    });
  });

  group('FUNC-EXT-006: ProjectMember model', () {
    test('fromJson with camelCase', () {
      final m = ProjectMember.fromJson({
        'id': 'pm-1',
        'userId': 'u-1',
        'userName': 'Alice',
        'userEmail': 'alice@test.com',
        'role': 'ADMIN',
        'joinedAt': '2024-01-01T00:00:00Z',
      });
      expect(m.userName, 'Alice');
      expect(m.role, ProjectRole.admin);
      expect(m.userAvatar, isNull);
    });

    test('fromJson with snake_case', () {
      final m = ProjectMember.fromJson({
        'id': 'pm-2',
        'user_id': 'u-2',
        'user_name': 'Bob',
        'user_email': 'bob@test.com',
        'user_avatar': 'https://avatar.url',
        'role': 'VIEWER',
        'joined_at': '2024-01-01T00:00:00Z',
      });
      expect(m.userId, 'u-2');
      expect(m.userAvatar, 'https://avatar.url');
      expect(m.role, ProjectRole.viewer);
    });
  });

  group('FUNC-EXT-007: Analytics submodels', () {
    test('PriorityCount fromJson', () {
      final pc = PriorityCount.fromJson({'priority': 'HIGH', 'count': 5});
      expect(pc.priority, 'HIGH');
      expect(pc.count, 5);
    });

    test('StatusCount fromJson', () {
      final sc = StatusCount.fromJson({'status': 'DONE', 'count': 12});
      expect(sc.status, 'DONE');
      expect(sc.count, 12);
    });

    test('TeamWorkload fromJson with snake_case', () {
      final tw = TeamWorkload.fromJson({
        'user_id': 'u-1',
        'name': 'Test',
        'avatar_url': 'https://avatar.url',
        'total': 10,
        'done': 5,
        'in_progress': 3,
      });
      expect(tw.userId, 'u-1');
      expect(tw.avatarUrl, 'https://avatar.url');
      expect(tw.inProgress, 3);
    });

    test('WeeklyStats fromJson with snake_case', () {
      final ws = WeeklyStats.fromJson({
        'week_start': '2024-01-01',
        'week_end': '2024-01-07',
        'created': 10,
        'completed': 8,
      });
      expect(ws.weekStart, '2024-01-01');
      expect(ws.weekEnd, '2024-01-07');
    });

    test('Analytics fromJson with snake_case', () {
      final analytics = Analytics.fromJson({
        'completion_rate': 80,
        'total_tasks': 100,
        'completed_tasks': 80,
        'overdue_tasks': 5,
        'avg_completion_days': 3.5,
        'tasks_by_priority': [
          {'priority': 'HIGH', 'count': 20},
        ],
        'tasks_by_status': [
          {'status': 'DONE', 'count': 80},
        ],
        'team_workload': [],
        'weekly_stats': [
          {'weekStart': '2024-01-01', 'weekEnd': '2024-01-07', 'created': 5, 'completed': 3},
        ],
      });
      expect(analytics.completionRate, 80);
      expect(analytics.tasksByPriority.length, 1);
      expect(analytics.weeklyStats.length, 1);
    });
  });

  group('FUNC-EXT-008: Dashboard models', () {
    test('DashboardMyTasks fromJson', () {
      final dmt = DashboardMyTasks.fromJson({
        'tasks': [
          {
            'id': 't-1',
            'title': 'Task 1',
            'status': 'TODO',
            'priority': 'HIGH',
            'createdAt': '2024-01-01T00:00:00Z',
            'updatedAt': '2024-01-01T00:00:00Z',
          },
        ],
        'totalCount': 1,
      });
      expect(dmt.tasks.length, 1);
      expect(dmt.totalCount, 1);
    });

    test('DashboardMyTasks with snake_case totalCount', () {
      final dmt = DashboardMyTasks.fromJson({
        'tasks': [],
        'total_count': 42,
      });
      expect(dmt.totalCount, 42);
    });

    test('ProjectDashboard fromJson', () {
      final pd = ProjectDashboard.fromJson({
        'tasksByStatus': {'TODO': 5, 'DONE': 3},
        'tasksByPriority': {'HIGH': 2, 'LOW': 6},
        'totalTasks': 8,
        'completedTasks': 3,
        'overdueTasks': 1,
      });
      expect(pd.tasksByStatus['TODO'], 5);
      expect(pd.tasksByPriority['HIGH'], 2);
      expect(pd.totalTasks, 8);
    });

    test('ProjectDashboard with empty maps', () {
      final pd = ProjectDashboard.fromJson(<String, dynamic>{});
      expect(pd.tasksByStatus, isEmpty);
      expect(pd.tasksByPriority, isEmpty);
      expect(pd.totalTasks, 0);
    });

    test('TrendDataPoint fromJson', () {
      final tp = TrendDataPoint.fromJson({
        'date': '2024-01-15',
        'created': 7,
        'completed': 4,
      });
      expect(tp.date, '2024-01-15');
      expect(tp.created, 7);
      expect(tp.completed, 4);
    });
  });

  group('FUNC-EXT-009: Task copyWith all fields', () {
    test('copyWith status', () {
      final task = createTestTask(status: TaskStatus.todo);
      final updated = task.copyWith(status: TaskStatus.done);
      expect(updated.status, TaskStatus.done);
      expect(updated.title, task.title);
    });

    test('copyWith priority', () {
      final task = createTestTask(priority: TaskPriority.low);
      final updated = task.copyWith(priority: TaskPriority.critical);
      expect(updated.priority, TaskPriority.critical);
    });

    test('copyWith dueDate', () {
      final task = createTestTask();
      final newDate = DateTime(2025, 6, 15);
      final updated = task.copyWith(dueDate: newDate);
      expect(updated.dueDate, newDate);
    });

    test('copyWith assigneeIds', () {
      final task = createTestTask();
      final updated = task.copyWith(assigneeIds: ['u-5', 'u-6']);
      expect(updated.assigneeIds.length, 2);
    });

    test('copyWith subTasks', () {
      final task = createTestTask();
      final updated = task.copyWith(subTasks: [
        createTestSubTask(id: 'new-sub'),
      ]);
      expect(updated.subTasks.length, 1);
    });

    test('copyWith position', () {
      final task = createTestTask();
      final updated = task.copyWith(position: 5);
      expect(updated.position, 5);
    });
  });

  group('FUNC-EXT-010: Task toJson output', () {
    test('toJson includes position', () {
      final task = createTestTask();
      final json = task.toJson();
      expect(json.containsKey('position'), true);
    });

    test('toJson includes assigneeIds', () {
      final task = createTestTask(assigneeIds: ['u-1']);
      final json = task.toJson();
      expect(json['assigneeIds'], ['u-1']);
    });

    test('toJson dueDate is null when not set', () {
      final task = createTestTask(dueDate: null);
      final json = task.toJson();
      expect(json['dueDate'], isNull);
    });

    test('toJson dueDate is ISO string when set', () {
      final task = createTestTask(dueDate: DateTime(2024, 12, 25));
      final json = task.toJson();
      expect(json['dueDate'], contains('2024-12-25'));
    });
  });

  group('FUNC-EXT-011: Enum display names', () {
    test('TaskStatus displayName values', () {
      expect(TaskStatus.todo.displayName, 'To Do');
      expect(TaskStatus.inProgress.displayName, 'In Progress');
      expect(TaskStatus.underReview.displayName, 'Under Review');
      expect(TaskStatus.done.displayName, 'Done');
      expect(TaskStatus.archived.displayName, 'Archived');
    });

    test('TaskPriority displayName values', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
      expect(TaskPriority.critical.displayName, 'Critical');
    });

    test('TaskStatus value strings', () {
      expect(TaskStatus.todo.value, 'TODO');
      expect(TaskStatus.inProgress.value, 'IN_PROGRESS');
      expect(TaskStatus.underReview.value, 'UNDER_REVIEW');
      expect(TaskStatus.done.value, 'DONE');
      expect(TaskStatus.archived.value, 'ARCHIVED');
    });

    test('TaskPriority value strings', () {
      expect(TaskPriority.low.value, 'LOW');
      expect(TaskPriority.medium.value, 'MEDIUM');
      expect(TaskPriority.high.value, 'HIGH');
      expect(TaskPriority.critical.value, 'CRITICAL');
    });
  });

  group('FUNC-EXT-012: User model edge cases', () {
    test('User with avatarUrl from snake_case', () {
      final u = User.fromJson({
        'id': 'u-1',
        'email': 'test@test.com',
        'name': 'Test',
        'avatar_url': 'https://avatar.com/img.png',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(u.avatarUrl, 'https://avatar.com/img.png');
    });

    test('User copyWith avatar and bio', () {
      final u = createTestUser();
      final updated = u.copyWith(
        avatarUrl: 'https://new-avatar.com',
        bio: 'New bio',
      );
      expect(updated.avatarUrl, 'https://new-avatar.com');
      expect(updated.bio, 'New bio');
      expect(updated.name, u.name);
    });
  });

  group('FUNC-EXT-013: AppNotification fromJson snake_case', () {
    test('All snake_case fields parsed', () {
      final n = AppNotification.fromJson({
        'id': 'n-1',
        'user_id': 'u-1',
        'type': 'DUE_SOON',
        'title': 'Due soon',
        'body': 'Task is due',
        'is_read': true,
        'created_at': '2024-01-01T00:00:00Z',
      });
      expect(n.userId, 'u-1');
      expect(n.type, NotificationType.dueSoon);
      expect(n.isRead, true);
    });

    test('link field parsed', () {
      final n = AppNotification.fromJson({
        'id': 'n-1',
        'type': 'COMMENT_ADDED',
        'title': 'Comment',
        'body': 'New comment',
        'link': '/tasks/t-1',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(n.link, '/tasks/t-1');
    });
  });

  group('FUNC-EXT-014: Project toJson', () {
    test('toJson has name and description', () {
      final p = createTestProject(name: 'My Proj', description: 'Desc');
      final json = p.toJson();
      expect(json['name'], 'My Proj');
      expect(json['description'], 'Desc');
      expect(json.length, 2);
    });
  });

  group('FUNC-EXT-015: ApiException fromDioException coverage', () {
    test('ApiException with null statusCode', () {
      final e = ApiException('Error');
      expect(e.statusCode, isNull);
      expect(e.message, 'Error');
    });

    test('ApiException toString returns only message', () {
      final e = ApiException('User not found', statusCode: 404);
      expect(e.toString(), 'User not found');
    });
  });

  group('FUNC-EXT-016: AuthTokens fromJson', () {
    test('fromJson parses tokens', () {
      final t = AuthTokens.fromJson({
        'accessToken': 'abc',
        'refreshToken': 'def',
      });
      expect(t.accessToken, 'abc');
      expect(t.refreshToken, 'def');
    });

    test('fromJson missing fields defaults to empty', () {
      final t = AuthTokens.fromJson(<String, dynamic>{});
      expect(t.accessToken, '');
      expect(t.refreshToken, '');
    });
  });

  group('FUNC-EXT-017: NotificationType value strings', () {
    test('Notification type values', () {
      expect(NotificationType.taskAssigned.value, 'TASK_ASSIGNED');
      expect(NotificationType.dueSoon.value, 'DUE_SOON');
      expect(NotificationType.commentAdded.value, 'COMMENT_ADDED');
    });
  });
}
