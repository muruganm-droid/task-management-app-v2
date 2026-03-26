// =============================================================================
// Phase 6: Hardening Tests
// Tests for: ViewModel edge cases, model safety, service error handling,
//            widget lifecycle, empty/error states, rapid state changes
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
import 'package:task_management_app/data/models/search_result.dart';
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
  // ===========================================================================
  // SECTION 1: ViewModel State Edge Cases
  // ===========================================================================

  group('HARDEN-001: TaskState filteredTasks edge cases', () {
    test('filteredTasks returns empty list when tasks is empty', () {
      const state = TaskState();
      expect(state.filteredTasks, isEmpty);
    });

    test('filteredTasks with all filters active on empty list', () {
      const state = TaskState(
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
        searchQuery: 'nonexistent',
      );
      expect(state.filteredTasks, isEmpty);
    });

    test('filteredTasks search is case insensitive', () {
      final state = TaskState(tasks: [
        createTestTask(title: 'UPPERCASE TITLE'),
        createTestTask(id: 'task-2', title: 'lowercase title'),
      ], searchQuery: 'uppercase');
      expect(state.filteredTasks.length, 1);
      expect(state.filteredTasks.first.title, 'UPPERCASE TITLE');
    });

    test('filteredTasks search in description', () {
      final state = TaskState(tasks: [
        createTestTask(title: 'Task', description: 'find me here'),
      ], searchQuery: 'find me');
      expect(state.filteredTasks.length, 1);
    });

    test('filteredTasks with null description does not crash', () {
      final state = TaskState(tasks: [
        createTestTask(title: 'Task', description: null),
      ], searchQuery: 'something');
      expect(state.filteredTasks, isEmpty);
    });

    test('getTasksByStatus returns correct subset', () {
      final state = TaskState(tasks: [
        createTestTask(id: 't1', status: TaskStatus.todo),
        createTestTask(id: 't2', status: TaskStatus.done),
        createTestTask(id: 't3', status: TaskStatus.todo),
      ]);
      expect(state.getTasksByStatus(TaskStatus.todo).length, 2);
      expect(state.getTasksByStatus(TaskStatus.done).length, 1);
      expect(state.getTasksByStatus(TaskStatus.inProgress).length, 0);
    });

    test('taskCountByStatus covers all statuses', () {
      const state = TaskState();
      final counts = state.taskCountByStatus;
      for (final status in TaskStatus.values) {
        expect(counts.containsKey(status), isTrue);
        expect(counts[status], 0);
      }
    });

    test('overdueTasks filters correctly', () {
      final state = TaskState(tasks: [
        createTestTask(
          id: 't1',
          status: TaskStatus.todo,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        createTestTask(
          id: 't2',
          status: TaskStatus.done,
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
        createTestTask(id: 't3', status: TaskStatus.todo),
      ]);
      expect(state.overdueTasks.length, 1);
      expect(state.overdueTasks.first.id, 't1');
    });
  });

  group('HARDEN-002: TaskState copyWith safety', () {
    test('copyWith preserves all fields when no args provided', () {
      final original = TaskState(
        tasks: [createTestTask()],
        selectedTask: createTestTask(),
        isLoading: true,
        error: 'some error',
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
        searchQuery: 'test',
      );
      final copy = original.copyWith();
      expect(copy.tasks.length, 1);
      expect(copy.selectedTask, isNotNull);
      expect(copy.isLoading, true);
      expect(copy.error, 'some error');
      expect(copy.statusFilter, TaskStatus.todo);
      expect(copy.priorityFilter, TaskPriority.high);
      expect(copy.searchQuery, 'test');
    });

    test('copyWith clearError removes error', () {
      const state = TaskState(error: 'err');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith clearSelectedTask removes selected task', () {
      final state = TaskState(selectedTask: createTestTask());
      final cleared = state.copyWith(clearSelectedTask: true);
      expect(cleared.selectedTask, isNull);
    });

    test('copyWith clearStatusFilter removes status filter', () {
      const state = TaskState(statusFilter: TaskStatus.done);
      final cleared = state.copyWith(clearStatusFilter: true);
      expect(cleared.statusFilter, isNull);
    });

    test('copyWith clearPriorityFilter removes priority filter', () {
      const state = TaskState(priorityFilter: TaskPriority.critical);
      final cleared = state.copyWith(clearPriorityFilter: true);
      expect(cleared.priorityFilter, isNull);
    });
  });

  group('HARDEN-003: AuthState edge cases', () {
    test('default AuthState is unauthenticated', () {
      const state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith clearError clears error', () {
      const state = AuthState(error: 'login failed');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith preserves user when not specified', () {
      final user = createTestUser();
      final state = AuthState(user: user, isAuthenticated: true);
      final copy = state.copyWith(isLoading: true);
      expect(copy.user, user);
      expect(copy.isAuthenticated, true);
    });
  });

  group('HARDEN-004: ProjectState edge cases', () {
    test('activeProjects excludes archived', () {
      final state = ProjectState(projects: [
        createTestProject(id: 'p1', isArchived: false),
        createTestProject(id: 'p2', isArchived: true),
        createTestProject(id: 'p3', isArchived: false),
      ]);
      expect(state.activeProjects.length, 2);
      expect(state.archivedProjects.length, 1);
    });

    test('empty state has empty lists', () {
      const state = ProjectState();
      expect(state.projects, isEmpty);
      expect(state.members, isEmpty);
      expect(state.labels, isEmpty);
      expect(state.activeProjects, isEmpty);
      expect(state.archivedProjects, isEmpty);
    });
  });

  group('HARDEN-005: DashboardState edge cases', () {
    test('empty dashboard has correct defaults', () {
      const state = DashboardState();
      expect(state.myTasks, isEmpty);
      expect(state.overdueTasks, isEmpty);
      expect(state.trends, isNull);
      expect(state.taskCountByStatus.values.every((v) => v == 0), true);
    });
  });

  group('HARDEN-006: NotificationState edge cases', () {
    test('unreadCount is 0 when all read', () {
      final state = NotificationState(notifications: [
        createTestNotification(id: 'n1', isRead: true),
        createTestNotification(id: 'n2', isRead: true),
      ]);
      expect(state.unreadCount, 0);
    });

    test('unreadCount counts unread correctly', () {
      final state = NotificationState(notifications: [
        createTestNotification(id: 'n1', isRead: false),
        createTestNotification(id: 'n2', isRead: true),
        createTestNotification(id: 'n3', isRead: false),
      ]);
      expect(state.unreadCount, 2);
    });
  });

  group('HARDEN-007: CommentState edge cases', () {
    test('default CommentState', () {
      const state = CommentState();
      expect(state.comments, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith preserves comments', () {
      final state = CommentState(comments: [createTestComment()]);
      final copy = state.copyWith(isLoading: true);
      expect(copy.comments.length, 1);
      expect(copy.isLoading, true);
    });
  });

  // ===========================================================================
  // SECTION 2: Model Safety - fromJson with malformed data
  // ===========================================================================

  group('HARDEN-008: Task.fromJson handles type mismatches', () {
    test('string id is preserved', () {
      final task = Task.fromJson({'id': 'task-abc', 'title': 'Test'});
      expect(task.id, 'task-abc');
      expect(task.title, 'Test');
    });

    test('nested subTasks with invalid entries are handled', () {
      final task = Task.fromJson({
        'id': 'task-1',
        'subTasks': [
          {'id': 'sub-1', 'title': 'Valid subtask'},
        ],
      });
      expect(task.subTasks.length, 1);
      expect(task.subTasks.first.title, 'Valid subtask');
    });

    test('invalid date string returns null dueDate', () {
      final task = Task.fromJson({
        'id': 'task-1',
        'dueDate': 'not-a-date',
      });
      expect(task.dueDate, isNull);
    });

    test('empty assigneeIds and labelIds default to empty lists', () {
      final task = Task.fromJson({'id': 'task-1'});
      expect(task.assigneeIds, isEmpty);
      expect(task.labelIds, isEmpty);
      expect(task.subTasks, isEmpty);
      expect(task.attachments, isEmpty);
    });
  });

  group('HARDEN-009: SubTask.fromJson safety', () {
    test('empty map produces safe defaults', () {
      final st = SubTask.fromJson({});
      expect(st.id, '');
      expect(st.taskId, '');
      expect(st.title, '');
      expect(st.isDone, false);
    });

    test('snake_case fields work', () {
      final st = SubTask.fromJson({
        'task_id': 'task-x',
        'is_done': true,
        'created_at': '2025-01-01T00:00:00.000Z',
      });
      expect(st.taskId, 'task-x');
      expect(st.isDone, true);
    });

    test('toJson produces expected keys', () {
      final st = SubTask(
        id: 'sub-1',
        taskId: 'task-1',
        title: 'Do thing',
        isDone: true,
        createdAt: DateTime(2025),
      );
      final json = st.toJson();
      expect(json['title'], 'Do thing');
      expect(json['isDone'], true);
    });
  });

  group('HARDEN-010: Project.fromJson safety', () {
    test('handles completely missing fields', () {
      final project = Project.fromJson({});
      expect(project.id, '');
      expect(project.name, '');
      expect(project.ownerId, '');
      expect(project.isArchived, false);
      expect(project.memberCount, 1);
      expect(project.taskCount, 0);
    });

    test('snake_case aliases work', () {
      final project = Project.fromJson({
        'owner_id': 'user-x',
        'is_archived': true,
        'member_count': 5,
        'task_count': 12,
      });
      expect(project.ownerId, 'user-x');
      expect(project.isArchived, true);
      expect(project.memberCount, 5);
      expect(project.taskCount, 12);
    });
  });

  group('HARDEN-011: ProjectMember.fromJson safety', () {
    test('empty map produces defaults', () {
      final pm = ProjectMember.fromJson({});
      expect(pm.id, '');
      expect(pm.userId, '');
      expect(pm.userName, '');
      expect(pm.userEmail, '');
      expect(pm.userAvatar, isNull);
      expect(pm.role, ProjectRole.member);
    });
  });

  group('HARDEN-012: Comment.fromJson safety', () {
    test('empty map produces defaults', () {
      final c = Comment.fromJson({});
      expect(c.id, '');
      expect(c.taskId, '');
      expect(c.authorName, 'Unknown');
      expect(c.body, '');
      expect(c.isEdited, false);
    });
  });

  group('HARDEN-013: AppNotification.fromJson safety', () {
    test('empty map produces defaults', () {
      final n = AppNotification.fromJson({});
      expect(n.id, '');
      expect(n.userId, '');
      expect(n.type, NotificationType.taskAssigned);
      expect(n.title, '');
      expect(n.body, '');
      expect(n.isRead, false);
    });

    test('copyWith preserves all fields', () {
      final n = AppNotification(
        id: 'n-1',
        userId: 'u-1',
        type: NotificationType.dueSoon,
        title: 'Due soon',
        body: 'Task is due',
        isRead: false,
        createdAt: DateTime(2025),
      );
      final copy = n.copyWith(isRead: true);
      expect(copy.isRead, true);
      expect(copy.id, 'n-1');
      expect(copy.type, NotificationType.dueSoon);
    });
  });

  group('HARDEN-014: AuthResponse.fromJson safety', () {
    test('missing user and tokens returns safe defaults', () {
      final ar = AuthResponse.fromJson({});
      expect(ar.user.id, '');
      expect(ar.tokens.accessToken, '');
      expect(ar.tokens.refreshToken, '');
    });

    test('non-map user value returns safe default', () {
      final ar = AuthResponse.fromJson({
        'user': 'not-a-map',
        'tokens': 'not-a-map',
      });
      expect(ar.user.id, '');
      expect(ar.tokens.accessToken, '');
    });
  });

  group('HARDEN-015: DashboardMyTasks.fromJson safety', () {
    test('empty map returns empty tasks and 0 count', () {
      final dmt = DashboardMyTasks.fromJson({});
      expect(dmt.tasks, isEmpty);
      expect(dmt.totalCount, 0);
    });

    test('null tasks list defaults to empty', () {
      final dmt = DashboardMyTasks.fromJson({'tasks': null});
      expect(dmt.tasks, isEmpty);
    });
  });

  group('HARDEN-016: ProjectDashboard.fromJson safety', () {
    test('empty map returns empty maps and 0 counts', () {
      final pd = ProjectDashboard.fromJson({});
      expect(pd.tasksByStatus, isEmpty);
      expect(pd.tasksByPriority, isEmpty);
      expect(pd.totalTasks, 0);
      expect(pd.completedTasks, 0);
      expect(pd.overdueTasks, 0);
    });
  });

  group('HARDEN-017: DashboardTrends.fromJson safety', () {
    test('list input produces trend data points', () {
      final dt = DashboardTrends.fromJson([
        {'date': '2025-01-01', 'created': 5, 'completed': 3},
      ]);
      expect(dt.dataPoints.length, 1);
      expect(dt.dataPoints.first.date, '2025-01-01');
    });

    test('map input with data key', () {
      final dt = DashboardTrends.fromJson({
        'data': [
          {'date': '2025-01-02', 'created': 2, 'completed': 1},
        ],
      });
      expect(dt.dataPoints.length, 1);
    });

    test('map input without data key returns empty', () {
      final dt = DashboardTrends.fromJson(<String, dynamic>{});
      expect(dt.dataPoints, isEmpty);
    });
  });

  group('HARDEN-018: TrendDataPoint.fromJson safety', () {
    test('empty map returns defaults', () {
      final tdp = TrendDataPoint.fromJson({});
      expect(tdp.date, '');
      expect(tdp.created, 0);
      expect(tdp.completed, 0);
    });
  });

  group('HARDEN-019: Activity.fromJson safety', () {
    test('empty map returns defaults', () {
      final a = Activity.fromJson({});
      expect(a.id, '');
      expect(a.userName, 'Unknown');
      expect(a.action, '');
      expect(a.details, isNull);
    });

    test('snake_case aliases work', () {
      final a = Activity.fromJson({
        'task_id': 'task-x',
        'user_id': 'user-x',
        'user_name': 'Alice',
      });
      expect(a.taskId, 'task-x');
      expect(a.userId, 'user-x');
      expect(a.userName, 'Alice');
    });
  });

  group('HARDEN-020: Label.fromJson safety', () {
    test('empty map returns defaults', () {
      final l = Label.fromJson({});
      expect(l.id, '');
      expect(l.projectId, '');
      expect(l.name, '');
      expect(l.colorHex, '#6B7280');
    });

    test('color getter parses hex correctly', () {
      final l = Label.fromJson({'color': '#FF5733'});
      expect(l.color, const Color(0xFFFF5733));
    });

    test('toJson roundtrip', () {
      final l = Label.fromJson({'name': 'Bug', 'color': '#FF0000'});
      final json = l.toJson();
      expect(json['name'], 'Bug');
      expect(json['color'], '#FF0000');
    });
  });

  group('HARDEN-021: SearchResult.fromJson safety', () {
    test('empty map returns empty lists', () {
      final sr = SearchResult.fromJson({});
      expect(sr.tasks, isEmpty);
      expect(sr.projects, isEmpty);
    });

    test('toJson roundtrip', () {
      final sr = SearchResult(tasks: [], projects: []);
      final json = sr.toJson();
      expect(json['tasks'], isEmpty);
      expect(json['projects'], isEmpty);
    });
  });

  // ===========================================================================
  // SECTION 3: Enum Safety
  // ===========================================================================

  group('HARDEN-022: TaskStatus.fromString safety', () {
    test('handles all valid values', () {
      expect(TaskStatus.fromString('TODO'), TaskStatus.todo);
      expect(TaskStatus.fromString('IN_PROGRESS'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('UNDER_REVIEW'), TaskStatus.underReview);
      expect(TaskStatus.fromString('DONE'), TaskStatus.done);
      expect(TaskStatus.fromString('ARCHIVED'), TaskStatus.archived);
    });

    test('case insensitive', () {
      expect(TaskStatus.fromString('todo'), TaskStatus.todo);
      expect(TaskStatus.fromString('Todo'), TaskStatus.todo);
    });

    test('unknown value defaults to todo', () {
      expect(TaskStatus.fromString('INVALID'), TaskStatus.todo);
      expect(TaskStatus.fromString(''), TaskStatus.todo);
    });
  });

  group('HARDEN-023: TaskPriority.fromString safety', () {
    test('handles all valid values', () {
      expect(TaskPriority.fromString('LOW'), TaskPriority.low);
      expect(TaskPriority.fromString('MEDIUM'), TaskPriority.medium);
      expect(TaskPriority.fromString('HIGH'), TaskPriority.high);
      expect(TaskPriority.fromString('CRITICAL'), TaskPriority.critical);
    });

    test('unknown value defaults to medium', () {
      expect(TaskPriority.fromString('INVALID'), TaskPriority.medium);
      expect(TaskPriority.fromString(''), TaskPriority.medium);
    });
  });

  group('HARDEN-024: NotificationType.fromString safety', () {
    test('handles all valid values', () {
      expect(NotificationType.fromString('TASK_ASSIGNED'),
          NotificationType.taskAssigned);
      expect(
          NotificationType.fromString('DUE_SOON'), NotificationType.dueSoon);
      expect(NotificationType.fromString('COMMENT_ADDED'),
          NotificationType.commentAdded);
    });

    test('unknown value defaults to taskAssigned', () {
      expect(NotificationType.fromString('UNKNOWN'),
          NotificationType.taskAssigned);
    });
  });

  group('HARDEN-025: ProjectRole.fromString safety', () {
    test('handles all valid values', () {
      expect(ProjectRole.fromString('OWNER'), ProjectRole.owner);
      expect(ProjectRole.fromString('ADMIN'), ProjectRole.admin);
      expect(ProjectRole.fromString('MEMBER'), ProjectRole.member);
      expect(ProjectRole.fromString('VIEWER'), ProjectRole.viewer);
    });

    test('unknown value defaults to member', () {
      expect(ProjectRole.fromString('UNKNOWN'), ProjectRole.member);
    });

    test('apiValue returns uppercase', () {
      expect(ProjectRole.owner.apiValue, 'OWNER');
      expect(ProjectRole.admin.apiValue, 'ADMIN');
    });

    test('displayName returns readable name', () {
      expect(ProjectRole.owner.displayName, 'Owner');
      expect(ProjectRole.viewer.displayName, 'Viewer');
    });
  });

  // ===========================================================================
  // SECTION 4: ApiException Safety
  // ===========================================================================

  group('HARDEN-026: ApiException', () {
    test('toString returns message only', () {
      final e = ApiException('Network error');
      expect(e.toString(), 'Network error');
    });

    test('statusCode is preserved', () {
      final e = ApiException('Not found', statusCode: 404);
      expect(e.statusCode, 404);
      expect(e.message, 'Not found');
    });

    test('statusCode defaults to null', () {
      final e = ApiException('Error');
      expect(e.statusCode, isNull);
    });
  });

  // ===========================================================================
  // SECTION 5: Task Model Computed Properties
  // ===========================================================================

  group('HARDEN-027: Task.isOverdue computed property', () {
    test('task with no dueDate is not overdue', () {
      final task = createTestTask(dueDate: null, status: TaskStatus.todo);
      expect(task.isOverdue, false);
    });

    test('task with future dueDate is not overdue', () {
      final task = createTestTask(
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, false);
    });

    test('task with past dueDate and status todo is overdue', () {
      final task = createTestTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, true);
    });

    test('done task with past dueDate is NOT overdue', () {
      final task = createTestTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.done,
      );
      expect(task.isOverdue, false);
    });

    test('archived task with past dueDate is NOT overdue', () {
      final task = createTestTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.archived,
      );
      expect(task.isOverdue, false);
    });
  });

  group('HARDEN-028: Task.completedSubTaskCount', () {
    test('returns 0 when no subtasks', () {
      final task = createTestTask(subTasks: []);
      expect(task.completedSubTaskCount, 0);
    });

    test('counts only done subtasks', () {
      final task = createTestTask(subTasks: [
        createTestSubTask(id: 's1', isDone: true),
        createTestSubTask(id: 's2', isDone: false),
        createTestSubTask(id: 's3', isDone: true),
      ]);
      expect(task.completedSubTaskCount, 2);
    });
  });

  group('HARDEN-029: Task.copyWith', () {
    test('preserves id, projectId, creatorId', () {
      final task = createTestTask(id: 'task-42');
      final copy = task.copyWith(title: 'New title');
      expect(copy.id, 'task-42');
      expect(copy.projectId, 'proj-1');
      expect(copy.creatorId, 'user-1');
      expect(copy.title, 'New title');
    });

    test('can update all mutable fields', () {
      final task = createTestTask();
      final updated = task.copyWith(
        title: 'Updated',
        description: 'Desc',
        status: TaskStatus.done,
        priority: TaskPriority.critical,
        dueDate: DateTime(2026),
        assigneeIds: ['u1', 'u2'],
        labelIds: ['l1'],
        position: 5,
      );
      expect(updated.title, 'Updated');
      expect(updated.status, TaskStatus.done);
      expect(updated.priority, TaskPriority.critical);
      expect(updated.assigneeIds, ['u1', 'u2']);
      expect(updated.position, 5);
    });
  });

  group('HARDEN-030: Task.toJson', () {
    test('includes expected fields', () {
      final task = createTestTask(
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
      );
      final json = task.toJson();
      expect(json['title'], 'Test Task');
      expect(json['status'], 'IN_PROGRESS');
      expect(json['priority'], 'HIGH');
      expect(json.containsKey('assigneeIds'), true);
    });
  });

  // ===========================================================================
  // SECTION 6: Widget Rendering with Edge Cases
  // ===========================================================================

  group('HARDEN-031: TaskCard renders with minimal task', () {
    testWidgets('renders task with only required fields', (tester) async {
      final task = Task.fromJson({
        'id': 'min',
        'title': 'Minimal',
        'status': 'TODO',
        'priority': 'LOW',
      });

      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: TaskCard(task: task, onTap: () {}),
        ),
      ));

      expect(find.text('Minimal'), findsOneWidget);
    });

    testWidgets('renders task with very long title', (tester) async {
      final longTitle = 'A' * 300;
      final task = createTestTask(title: longTitle);

      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: TaskCard(task: task, onTap: () {}),
          ),
        ),
      ));

      expect(find.byType(TaskCard), findsOneWidget);
    });

    testWidgets('renders task with emoji in title', (tester) async {
      final task = createTestTask(title: 'Fix bug 🐛🔥✨');

      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: TaskCard(task: task, onTap: () {}),
        ),
      ));

      expect(find.byType(TaskCard), findsOneWidget);
    });
  });

  group('HARDEN-032: PriorityBadge renders all priorities', () {
    for (final priority in TaskPriority.values) {
      testWidgets('renders ${priority.displayName}', (tester) async {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: PriorityBadge(priority: priority),
          ),
        ));

        expect(find.byType(PriorityBadge), findsOneWidget);
      });
    }
  });

  group('HARDEN-033: StatusBadge renders all statuses', () {
    for (final status in TaskStatus.values) {
      testWidgets('renders ${status.displayName}', (tester) async {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(
            body: StatusBadge(status: status),
          ),
        ));

        expect(find.byType(StatusBadge), findsOneWidget);
      });
    }
  });

  group('HARDEN-034: EmptyState renders correctly', () {
    testWidgets('renders with all props', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No tasks',
            subtitle: 'Create one to get started',
          ),
        ),
      ));

      // Pump a frame to let FadeInWidget and float animation start
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No tasks'), findsOneWidget);
      expect(find.text('Create one to get started'), findsOneWidget);

      // Dispose cleanly by removing the widget (stops repeating animation)
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ===========================================================================
  // SECTION 7: Attachment Model Safety
  // ===========================================================================

  group('HARDEN-035: Attachment.isImage property', () {
    test('image/jpeg is image', () {
      final att = Attachment.fromJson({
        'mimeType': 'image/jpeg',
        'fileSize': 100,
      });
      expect(att.isImage, true);
    });

    test('application/pdf is not image', () {
      final att = Attachment.fromJson({
        'mimeType': 'application/pdf',
        'fileSize': 100,
      });
      expect(att.isImage, false);
    });

    test('empty mimeType is not image', () {
      final att = Attachment.fromJson({});
      expect(att.isImage, false);
    });
  });

  group('HARDEN-036: Attachment.toJson roundtrip', () {
    test('toJson preserves all fields', () {
      final att = Attachment(
        id: 'a-1',
        taskId: 't-1',
        uploaderId: 'u-1',
        fileName: 'file.txt',
        fileUrl: 'https://example.com/file.txt',
        mimeType: 'text/plain',
        fileSize: 1024,
        createdAt: DateTime(2025, 6, 15),
      );
      final json = att.toJson();
      expect(json['id'], 'a-1');
      expect(json['fileName'], 'file.txt');
      expect(json['fileSize'], 1024);
    });
  });

  // ===========================================================================
  // SECTION 8: User Model Safety
  // ===========================================================================

  group('HARDEN-037: User.fromJson safety', () {
    test('empty map produces safe defaults', () {
      final user = User.fromJson({});
      expect(user.id, '');
      expect(user.email, '');
      expect(user.name, '');
      expect(user.avatarUrl, isNull);
      expect(user.bio, isNull);
    });

    test('toJson roundtrip', () {
      final user = createTestUser(name: 'Alice');
      final json = user.toJson();
      expect(json['name'], 'Alice');
      expect(json['email'], 'test@example.com');
    });

    test('copyWith updates specified fields', () {
      final user = createTestUser(name: 'Alice');
      final updated = user.copyWith(name: 'Bob', bio: 'New bio');
      expect(updated.name, 'Bob');
      expect(updated.bio, 'New bio');
      expect(updated.email, 'test@example.com');
    });
  });

  // ===========================================================================
  // SECTION 9: Rapid State Changes
  // ===========================================================================

  group('HARDEN-038: Rapid filter changes do not corrupt state', () {
    test('rapidly changing filters produces correct final state', () {
      var state = const TaskState(tasks: []);
      state = state.copyWith(statusFilter: TaskStatus.todo);
      state = state.copyWith(clearStatusFilter: true);
      state = state.copyWith(priorityFilter: TaskPriority.high);
      state = state.copyWith(clearPriorityFilter: true);
      state = state.copyWith(searchQuery: 'test');
      state = state.copyWith(searchQuery: '');

      expect(state.statusFilter, isNull);
      expect(state.priorityFilter, isNull);
      expect(state.searchQuery, '');
    });
  });

  group('HARDEN-039: Analytics model with extreme values', () {
    test('handles zero completion rate', () {
      final a = Analytics.fromJson({
        'completionRate': 0,
        'totalTasks': 0,
        'completedTasks': 0,
        'overdueTasks': 0,
        'avgCompletionDays': 0,
      });
      expect(a.completionRate, 0);
      expect(a.avgCompletionDays, 0.0);
    });

    test('handles 100% completion rate', () {
      final a = Analytics.fromJson({
        'completionRate': 100,
        'totalTasks': 50,
        'completedTasks': 50,
      });
      expect(a.completionRate, 100);
      expect(a.completedTasks, 50);
    });

    test('handles float avgCompletionDays', () {
      final a = Analytics.fromJson({'avgCompletionDays': 3.14159});
      expect(a.avgCompletionDays, closeTo(3.14159, 0.001));
    });
  });

  group('HARDEN-040: Widget unmount safety', () {
    testWidgets('TaskCard can be removed from tree without error',
        (tester) async {
      final task = createTestTask();
      bool showCard = true;

      await tester.pumpWidget(createTestApp(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  if (showCard)
                    TaskCard(task: task, onTap: () {}),
                  ElevatedButton(
                    onPressed: () => setState(() => showCard = false),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            );
          },
        ),
      ));

      expect(find.byType(TaskCard), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      expect(find.byType(TaskCard), findsNothing);
    });
  });
}
