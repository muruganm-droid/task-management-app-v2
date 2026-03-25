import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/attachment.dart';

void main() {
  // ─── Shared fixture data ─────────────────────────────────────────────────

  Map<String, dynamic> _baseTaskJson() => {
        'id': 'task-001',
        'projectId': 'proj-001',
        'title': 'Fix login bug',
        'description': 'Repro steps in Jira',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'dueDate': '2025-12-31T23:59:59.000Z',
        'creatorId': 'user-001',
        'assigneeIds': ['user-002', 'user-003'],
        'labelIds': ['label-a', 'label-b'],
        'subTasks': [
          {
            'id': 'sub-001',
            'taskId': 'task-001',
            'title': 'Write unit test',
            'isDone': true,
            'createdAt': '2025-01-01T00:00:00.000Z',
          },
        ],
        'position': 3,
        'attachments': [
          {
            'id': 'att-001',
            'taskId': 'task-001',
            'uploaderId': 'user-001',
            'fileName': 'screenshot.png',
            'fileUrl': 'https://cdn.example.com/screenshot.png',
            'mimeType': 'image/png',
            'fileSize': 204800,
            'createdAt': '2025-01-02T10:00:00.000Z',
          },
        ],
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-06-01T12:00:00.000Z',
      };

  // ─── Task.fromJson ────────────────────────────────────────────────────────

  group('Task.fromJson', () {
    test('parses all camelCase fields correctly', () {
      final task = Task.fromJson(_baseTaskJson());

      expect(task.id, 'task-001');
      expect(task.projectId, 'proj-001');
      expect(task.title, 'Fix login bug');
      expect(task.description, 'Repro steps in Jira');
      expect(task.status, TaskStatus.inProgress);
      expect(task.priority, TaskPriority.high);
      expect(task.dueDate, DateTime.parse('2025-12-31T23:59:59.000Z'));
      expect(task.creatorId, 'user-001');
      expect(task.assigneeIds, ['user-002', 'user-003']);
      expect(task.labelIds, ['label-a', 'label-b']);
      expect(task.position, 3);
      expect(task.createdAt, DateTime.parse('2025-01-01T00:00:00.000Z'));
      expect(task.updatedAt, DateTime.parse('2025-06-01T12:00:00.000Z'));
    });

    test('parses subTasks list', () {
      final task = Task.fromJson(_baseTaskJson());

      expect(task.subTasks.length, 1);
      expect(task.subTasks.first.id, 'sub-001');
      expect(task.subTasks.first.title, 'Write unit test');
      expect(task.subTasks.first.isDone, isTrue);
    });

    test('parses attachments list', () {
      final task = Task.fromJson(_baseTaskJson());

      expect(task.attachments.length, 1);
      expect(task.attachments.first.id, 'att-001');
      expect(task.attachments.first.fileName, 'screenshot.png');
      expect(task.attachments.first.mimeType, 'image/png');
      expect(task.attachments.first.fileSize, 204800);
    });

    test('accepts snake_case field aliases', () {
      final json = {
        'id': 'task-002',
        'project_id': 'proj-002',
        'title': 'Snake case task',
        'status': 'TODO',
        'priority': 'LOW',
        'creator_id': 'user-010',
        'assignee_ids': ['user-011'],
        'label_ids': <String>[],
        'sub_tasks': <Map<String, dynamic>>[],
        'position': 0,
        'attachments': <Map<String, dynamic>>[],
        'created_at': '2025-03-01T00:00:00.000Z',
        'updated_at': '2025-03-02T00:00:00.000Z',
      };

      final task = Task.fromJson(json);

      expect(task.projectId, 'proj-002');
      expect(task.creatorId, 'user-010');
      expect(task.assigneeIds, ['user-011']);
    });

    test('dueDate is null when both dueDate and due_date are absent', () {
      final json = Map<String, dynamic>.from(_baseTaskJson())
        ..remove('dueDate');
      final task = Task.fromJson(json);
      expect(task.dueDate, isNull);
    });

    test('position defaults to 0 when absent', () {
      final json = Map<String, dynamic>.from(_baseTaskJson())
        ..remove('position');
      final task = Task.fromJson(json);
      expect(task.position, 0);
    });

    test('attachments defaults to empty list when absent', () {
      final json = Map<String, dynamic>.from(_baseTaskJson())
        ..remove('attachments');
      final task = Task.fromJson(json);
      expect(task.attachments, isEmpty);
    });

    test('assigneeIds defaults to empty list when absent', () {
      final json = Map<String, dynamic>.from(_baseTaskJson())
        ..remove('assigneeIds');
      final task = Task.fromJson(json);
      expect(task.assigneeIds, isEmpty);
    });

    test('description can be null', () {
      final json = Map<String, dynamic>.from(_baseTaskJson())
        ..remove('description');
      final task = Task.fromJson(json);
      expect(task.description, isNull);
    });
  });

  // ─── Task.copyWith ────────────────────────────────────────────────────────

  group('Task.copyWith', () {
    late Task original;

    setUp(() {
      original = Task.fromJson(_baseTaskJson());
    });

    test('returns a new Task with updated title', () {
      final updated = original.copyWith(title: 'New Title');

      expect(updated.title, 'New Title');
      expect(updated.id, original.id);
      expect(updated.projectId, original.projectId);
    });

    test('returns a new Task with updated status', () {
      final updated = original.copyWith(status: TaskStatus.done);

      expect(updated.status, TaskStatus.done);
      expect(updated.title, original.title);
    });

    test('returns a new Task with updated priority', () {
      final updated = original.copyWith(priority: TaskPriority.critical);
      expect(updated.priority, TaskPriority.critical);
    });

    test('returns a new Task with updated position', () {
      final updated = original.copyWith(position: 99);
      expect(updated.position, 99);
      expect(original.position, 3); // original unchanged
    });

    test('returns a new Task with updated attachments', () {
      final newAtt = Attachment(
        id: 'att-new',
        taskId: 'task-001',
        uploaderId: 'user-001',
        fileName: 'doc.pdf',
        fileUrl: 'https://cdn.example.com/doc.pdf',
        mimeType: 'application/pdf',
        fileSize: 10240,
        createdAt: DateTime(2025, 5, 1),
      );

      final updated = original.copyWith(attachments: [newAtt]);
      expect(updated.attachments.length, 1);
      expect(updated.attachments.first.id, 'att-new');
    });

    test('preserves original values when no arguments supplied', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.status, original.status);
      expect(copy.position, original.position);
    });
  });

  // ─── Task.isOverdue ───────────────────────────────────────────────────────

  group('Task.isOverdue', () {
    Task _makeTask({
      required DateTime? dueDate,
      required TaskStatus status,
    }) {
      return Task(
        id: 'task-x',
        projectId: 'proj-x',
        title: 'Test',
        status: status,
        priority: TaskPriority.medium,
        dueDate: dueDate,
        creatorId: 'user-x',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    }

    test('is overdue when dueDate is in the past and status is todo', () {
      final task = _makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, isTrue);
    });

    test('is overdue when dueDate is in the past and status is inProgress', () {
      final task = _makeTask(
        dueDate: DateTime.now().subtract(const Duration(hours: 1)),
        status: TaskStatus.inProgress,
      );
      expect(task.isOverdue, isTrue);
    });

    test('is NOT overdue when status is done', () {
      final task = _makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.done,
      );
      expect(task.isOverdue, isFalse);
    });

    test('is NOT overdue when status is archived', () {
      final task = _makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: TaskStatus.archived,
      );
      expect(task.isOverdue, isFalse);
    });

    test('is NOT overdue when dueDate is in the future', () {
      final task = _makeTask(
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: TaskStatus.todo,
      );
      expect(task.isOverdue, isFalse);
    });

    test('is NOT overdue when dueDate is null', () {
      final task = _makeTask(dueDate: null, status: TaskStatus.todo);
      expect(task.isOverdue, isFalse);
    });
  });

  // ─── TaskStatus.fromString ────────────────────────────────────────────────

  group('TaskStatus.fromString', () {
    test('parses TODO', () {
      expect(TaskStatus.fromString('TODO'), TaskStatus.todo);
    });

    test('parses IN_PROGRESS', () {
      expect(TaskStatus.fromString('IN_PROGRESS'), TaskStatus.inProgress);
    });

    test('parses UNDER_REVIEW', () {
      expect(TaskStatus.fromString('UNDER_REVIEW'), TaskStatus.underReview);
    });

    test('parses DONE', () {
      expect(TaskStatus.fromString('DONE'), TaskStatus.done);
    });

    test('parses ARCHIVED', () {
      expect(TaskStatus.fromString('ARCHIVED'), TaskStatus.archived);
    });

    test('is case-insensitive', () {
      expect(TaskStatus.fromString('todo'), TaskStatus.todo);
      expect(TaskStatus.fromString('Done'), TaskStatus.done);
      expect(TaskStatus.fromString('in_progress'), TaskStatus.inProgress);
    });

    test('returns todo for unknown value', () {
      expect(TaskStatus.fromString('UNKNOWN_STATUS'), TaskStatus.todo);
    });
  });

  // ─── TaskPriority.fromString ──────────────────────────────────────────────

  group('TaskPriority.fromString', () {
    test('parses LOW', () {
      expect(TaskPriority.fromString('LOW'), TaskPriority.low);
    });

    test('parses MEDIUM', () {
      expect(TaskPriority.fromString('MEDIUM'), TaskPriority.medium);
    });

    test('parses HIGH', () {
      expect(TaskPriority.fromString('HIGH'), TaskPriority.high);
    });

    test('parses CRITICAL', () {
      expect(TaskPriority.fromString('CRITICAL'), TaskPriority.critical);
    });

    test('is case-insensitive', () {
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('Critical'), TaskPriority.critical);
    });

    test('returns medium for unknown value', () {
      expect(TaskPriority.fromString('UNKNOWN'), TaskPriority.medium);
    });
  });
}
