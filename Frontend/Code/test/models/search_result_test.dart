import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/search_result.dart';

void main() {
  // ─── Minimal task JSON helper ─────────────────────────────────────────────

  Map<String, dynamic> _taskJson({
    String id = 'task-001',
    String title = 'Test Task',
  }) =>
      {
        'id': id,
        'projectId': 'proj-001',
        'title': title,
        'status': 'TODO',
        'priority': 'MEDIUM',
        'creatorId': 'user-001',
        'assigneeIds': <String>[],
        'labelIds': <String>[],
        'subTasks': <Map<String, dynamic>>[],
        'position': 0,
        'attachments': <Map<String, dynamic>>[],
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T00:00:00.000Z',
      };

  Map<String, dynamic> _projectJson({
    String id = 'proj-001',
    String name = 'Test Project',
  }) =>
      {
        'id': id,
        'name': name,
        'ownerId': 'user-001',
        'isArchived': false,
        'memberCount': 2,
        'taskCount': 5,
        'createdAt': '2025-01-01T00:00:00.000Z',
        'updatedAt': '2025-01-01T00:00:00.000Z',
      };

  // ─── SearchResult.fromJson ────────────────────────────────────────────────

  group('SearchResult.fromJson', () {
    test('parses tasks list', () {
      final json = {
        'tasks': [
          _taskJson(id: 'task-001', title: 'Fix bug'),
          _taskJson(id: 'task-002', title: 'Write docs'),
        ],
        'projects': <Map<String, dynamic>>[],
      };

      final result = SearchResult.fromJson(json);

      expect(result.tasks.length, 2);
      expect(result.tasks[0].id, 'task-001');
      expect(result.tasks[0].title, 'Fix bug');
      expect(result.tasks[1].id, 'task-002');
      expect(result.tasks[1].title, 'Write docs');
    });

    test('parses projects list', () {
      final json = {
        'tasks': <Map<String, dynamic>>[],
        'projects': [
          _projectJson(id: 'proj-001', name: 'Alpha'),
          _projectJson(id: 'proj-002', name: 'Beta'),
        ],
      };

      final result = SearchResult.fromJson(json);

      expect(result.projects.length, 2);
      expect(result.projects[0].id, 'proj-001');
      expect(result.projects[0].name, 'Alpha');
      expect(result.projects[1].id, 'proj-002');
      expect(result.projects[1].name, 'Beta');
    });

    test('parses both tasks and projects together', () {
      final json = {
        'tasks': [_taskJson()],
        'projects': [_projectJson()],
      };

      final result = SearchResult.fromJson(json);

      expect(result.tasks.length, 1);
      expect(result.projects.length, 1);
    });

    test('tasks defaults to empty list when key absent', () {
      final result = SearchResult.fromJson({
        'projects': <Map<String, dynamic>>[],
      });

      expect(result.tasks, isEmpty);
    });

    test('projects defaults to empty list when key absent', () {
      final result = SearchResult.fromJson({
        'tasks': <Map<String, dynamic>>[],
      });

      expect(result.projects, isEmpty);
    });

    test('both lists default to empty when json is empty', () {
      final result = SearchResult.fromJson({});

      expect(result.tasks, isEmpty);
      expect(result.projects, isEmpty);
    });

    test('task fields are correctly mapped from nested JSON', () {
      final json = {
        'tasks': [
          _taskJson(id: 'task-abc', title: 'Deploy to prod'),
        ],
        'projects': <Map<String, dynamic>>[],
      };

      final result = SearchResult.fromJson(json);
      final task = result.tasks.first;

      expect(task.id, 'task-abc');
      expect(task.title, 'Deploy to prod');
      expect(task.projectId, 'proj-001');
    });

    test('project fields are correctly mapped from nested JSON', () {
      final json = {
        'tasks': <Map<String, dynamic>>[],
        'projects': [
          _projectJson(id: 'proj-xyz', name: 'Gamma Release'),
        ],
      };

      final result = SearchResult.fromJson(json);
      final project = result.projects.first;

      expect(project.id, 'proj-xyz');
      expect(project.name, 'Gamma Release');
      expect(project.ownerId, 'user-001');
    });
  });
}
