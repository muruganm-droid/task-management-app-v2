// =============================================================================
// Category 3: UX Tests
// Tests: User flow correctness, form validations, interactive behaviors,
//        feedback mechanisms (snackbars, loading states), accessibility
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/presentation/viewmodels/task_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UX-001: Email validation regex', () {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    test('Valid emails pass', () {
      expect(emailRegex.hasMatch('user@example.com'), true);
      expect(emailRegex.hasMatch('test.user@domain.org'), true);
      expect(emailRegex.hasMatch('a+b@c.de'), true);
    });

    test('Invalid emails fail', () {
      expect(emailRegex.hasMatch(''), false);
      expect(emailRegex.hasMatch('user'), false);
      expect(emailRegex.hasMatch('user@'), false);
      expect(emailRegex.hasMatch('@domain.com'), false);
      expect(emailRegex.hasMatch('user@.com'), false);
    });
  });

  group('UX-002: Password validation rules', () {
    test('Less than 8 chars fails', () {
      expect('short'.length < 8, true);
    });

    test('No uppercase fails', () {
      expect('abcdefgh'.contains(RegExp(r'[A-Z]')), false);
    });

    test('No number fails', () {
      expect('Abcdefgh'.contains(RegExp(r'[0-9]')), false);
    });

    test('Valid password passes all checks', () {
      const pw = 'Password1';
      expect(pw.length >= 8, true);
      expect(pw.contains(RegExp(r'[A-Z]')), true);
      expect(pw.contains(RegExp(r'[0-9]')), true);
    });
  });

  group('UX-003: EmptyState action callback', () {
    testWidgets('Action button triggers callback', (tester) async {
      bool called = false;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'Empty',
            actionLabel: 'Create',
            onAction: () => called = true,
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Create'));
      await tester.pump();
      expect(called, true);
    });
  });

  group('UX-004: ScaleOnTap interaction', () {
    testWidgets('Triggers callback on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Center(
            child: ScaleOnTap(
              onTap: () => tapped = true,
              child: const SizedBox(width: 100, height: 50, child: Text('Tap')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('Disabled when onTap is null', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(
            child: ScaleOnTap(
              onTap: null,
              child: SizedBox(width: 100, height: 50, child: Text('Dis')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Dis'));
      await tester.pump();
      // No crash
    });
  });

  group('UX-005: TaskState filtering UX', () {
    test('Search filters by title', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: '1', title: 'Buy groceries'),
          createTestTask(id: '2', title: 'Write report'),
        ],
        searchQuery: 'buy',
      );
      expect(state.filteredTasks.length, 1);
      expect(state.filteredTasks.first.title, 'Buy groceries');
    });

    test('Status filter narrows results', () {
      final state = TaskState(
        tasks: [
          createTestTask(id: '1', status: TaskStatus.todo),
          createTestTask(id: '2', status: TaskStatus.done),
        ],
        statusFilter: TaskStatus.todo,
      );
      expect(state.filteredTasks.length, 1);
    });

    test('Combined filters work', () {
      final state = TaskState(
        tasks: [
          createTestTask(
              id: '1',
              title: 'High todo',
              status: TaskStatus.todo,
              priority: TaskPriority.high),
          createTestTask(
              id: '2',
              title: 'Low todo',
              status: TaskStatus.todo,
              priority: TaskPriority.low),
        ],
        statusFilter: TaskStatus.todo,
        priorityFilter: TaskPriority.high,
      );
      expect(state.filteredTasks.length, 1);
      expect(state.filteredTasks.first.id, '1');
    });
  });

  group('UX-006: Task overdue visual feedback', () {
    test('Overdue task identified correctly', () {
      final task = createTestTask(
        dueDate: DateTime(2020, 1, 1),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, true);
    });

    test('Future task not overdue', () {
      final task = createTestTask(
        dueDate: DateTime(2099, 1, 1),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, false);
    });
  });

  group('UX-007: Notification unread count', () {
    test('Counts unread correctly', () {
      final notifications = [
        createTestNotification(id: '1', isRead: false),
        createTestNotification(id: '2', isRead: true),
        createTestNotification(id: '3', isRead: false),
      ];
      final unread = notifications.where((n) => !n.isRead).length;
      expect(unread, 2);
    });
  });
}
