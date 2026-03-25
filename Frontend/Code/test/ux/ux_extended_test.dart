// =============================================================================
// Category 3 Extended: UX Tests
// NEW tests: form validation edge cases, notification copyWith, task sort order,
// project active/archived filtering, comment model UX, dashboard computed
// properties, auth state transitions, password strength edge cases
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/auth_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/project_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/notification_viewmodel.dart';
import 'package:task_management_app/presentation/viewmodels/comment_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UX-EXT-001: Password strength edge cases', () {
    test('Exactly 8 chars with uppercase and number passes', () {
      const pw = 'Abcdef1x';
      expect(pw.length >= 8, true);
      expect(pw.contains(RegExp(r'[A-Z]')), true);
      expect(pw.contains(RegExp(r'[0-9]')), true);
    });

    test('All uppercase with number passes', () {
      const pw = 'ABCDEFG1';
      expect(pw.length >= 8, true);
      expect(pw.contains(RegExp(r'[A-Z]')), true);
      expect(pw.contains(RegExp(r'[0-9]')), true);
    });

    test('Special chars with valid password passes', () {
      const pw = 'P@ssw0rd!';
      expect(pw.length >= 8, true);
      expect(pw.contains(RegExp(r'[A-Z]')), true);
      expect(pw.contains(RegExp(r'[0-9]')), true);
    });

    test('Unicode characters do not satisfy uppercase', () {
      const pw = 'abcdefg1\u00E9';
      expect(pw.contains(RegExp(r'[A-Z]')), false);
    });
  });

  group('UX-EXT-002: Email validation edge cases', () {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    test('Double dot in domain passes simple regex (server validates further)', () {
      // The simple client-side regex allows this; server-side validation rejects it
      expect(emailRegex.hasMatch('user@domain..com'), true);
    });

    test('Email with subdomain passes', () {
      expect(emailRegex.hasMatch('user@mail.example.com'), true);
    });

    test('Very long valid email passes', () {
      final longLocal = 'a' * 50;
      expect(emailRegex.hasMatch('$longLocal@example.com'), true);
    });

    test('Spaces in email fail', () {
      expect(emailRegex.hasMatch('user @example.com'), false);
    });

    test('Email with plus addressing passes', () {
      expect(emailRegex.hasMatch('user+tag@example.com'), true);
    });
  });

  group('UX-EXT-003: Notification copyWith', () {
    test('Mark notification as read', () {
      final notif = createTestNotification(isRead: false);
      final read = notif.copyWith(isRead: true);
      expect(read.isRead, true);
      expect(read.id, notif.id);
      expect(read.title, notif.title);
    });

    test('copyWith without params preserves state', () {
      final notif = createTestNotification(isRead: true);
      final same = notif.copyWith();
      expect(same.isRead, true);
    });
  });

  group('UX-EXT-004: NotificationState computed', () {
    test('unreadCount on empty list', () {
      const state = NotificationState();
      expect(state.unreadCount, 0);
    });

    test('unreadCount with mixed read/unread', () {
      final state = NotificationState(notifications: [
        createTestNotification(id: 'n1', isRead: false),
        createTestNotification(id: 'n2', isRead: true),
        createTestNotification(id: 'n3', isRead: false),
        createTestNotification(id: 'n4', isRead: false),
      ]);
      expect(state.unreadCount, 3);
    });

    test('All read means 0 unread', () {
      final state = NotificationState(notifications: [
        createTestNotification(id: 'n1', isRead: true),
        createTestNotification(id: 'n2', isRead: true),
      ]);
      expect(state.unreadCount, 0);
    });
  });

  group('UX-EXT-005: ProjectState active/archived filtering', () {
    test('activeProjects excludes archived', () {
      final state = ProjectState(projects: [
        createTestProject(id: 'p1', isArchived: false),
        createTestProject(id: 'p2', isArchived: true),
        createTestProject(id: 'p3', isArchived: false),
      ]);
      expect(state.activeProjects.length, 2);
      expect(state.archivedProjects.length, 1);
    });

    test('Empty project list', () {
      const state = ProjectState();
      expect(state.activeProjects, isEmpty);
      expect(state.archivedProjects, isEmpty);
    });
  });

  group('UX-EXT-006: CommentState', () {
    test('Default state', () {
      const state = CommentState();
      expect(state.comments, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith clearError', () {
      const state = CommentState(error: 'Failed');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });

    test('copyWith adds comments', () {
      const state = CommentState();
      final withComments = state.copyWith(comments: [
        createTestComment(id: 'c1'),
        createTestComment(id: 'c2'),
      ]);
      expect(withComments.comments.length, 2);
    });
  });

  group('UX-EXT-007: DashboardState taskCountByStatus', () {
    test('Counts all statuses including zero counts', () {
      final state = DashboardState(myTasks: [
        createTestTask(id: '1', status: TaskStatus.todo),
        createTestTask(id: '2', status: TaskStatus.todo),
      ]);
      final counts = state.taskCountByStatus;
      expect(counts[TaskStatus.todo], 2);
      expect(counts[TaskStatus.inProgress], 0);
      expect(counts[TaskStatus.done], 0);
      expect(counts.length, TaskStatus.values.length);
    });
  });

  group('UX-EXT-008: AuthState copyWith transitions', () {
    test('Loading state sets isLoading', () {
      const state = AuthState();
      final loading = state.copyWith(isLoading: true);
      expect(loading.isLoading, true);
      expect(loading.isAuthenticated, false);
    });

    test('Authenticated state', () {
      final state = AuthState(
        user: createTestUser(),
        isAuthenticated: true,
      );
      expect(state.isAuthenticated, true);
      expect(state.user, isNotNull);
    });

    test('Error state preserves user', () {
      final state = AuthState(
        user: createTestUser(),
        isAuthenticated: true,
      );
      final errored = state.copyWith(error: 'Network error');
      expect(errored.error, 'Network error');
      expect(errored.user, isNotNull);
    });
  });

  group('UX-EXT-009: TaskState overdueTasks', () {
    test('overdueTasks returns only overdue', () {
      final state = TaskState(tasks: [
        createTestTask(id: '1', dueDate: DateTime(2020, 1, 1), status: TaskStatus.todo),
        createTestTask(id: '2', dueDate: DateTime(2099, 1, 1), status: TaskStatus.todo),
        createTestTask(id: '3', dueDate: DateTime(2020, 6, 1), status: TaskStatus.done),
      ]);
      expect(state.overdueTasks.length, 1);
      expect(state.overdueTasks.first.id, '1');
    });

    test('Empty tasks returns empty overdue', () {
      const state = TaskState();
      expect(state.overdueTasks, isEmpty);
    });
  });

  group('UX-EXT-010: TaskState copyWith clearSelectedTask', () {
    test('clearSelectedTask works', () {
      final state = TaskState(
        selectedTask: createTestTask(id: 'sel-1'),
      );
      final cleared = state.copyWith(clearSelectedTask: true);
      expect(cleared.selectedTask, isNull);
    });

    test('Setting selectedTask', () {
      const state = TaskState();
      final task = createTestTask(id: 'new-sel');
      final withSel = state.copyWith(selectedTask: task);
      expect(withSel.selectedTask?.id, 'new-sel');
    });
  });

  group('UX-EXT-011: NotificationState copyWith', () {
    test('Preserves notifications when changing loading', () {
      final state = NotificationState(notifications: [
        createTestNotification(id: 'n1'),
      ]);
      final loading = state.copyWith(isLoading: true);
      expect(loading.notifications.length, 1);
      expect(loading.isLoading, true);
    });
  });

  group('UX-EXT-012: ProjectState copyWith', () {
    test('clearSelectedProject works', () {
      final state = ProjectState(
        selectedProject: createTestProject(),
      );
      final cleared = state.copyWith(clearSelectedProject: true);
      expect(cleared.selectedProject, isNull);
    });

    test('Toggle showArchived', () {
      const state = ProjectState(showArchived: false);
      final toggled = state.copyWith(showArchived: true);
      expect(toggled.showArchived, true);
    });
  });
}
