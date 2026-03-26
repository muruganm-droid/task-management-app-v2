import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/analytics.dart';

void main() {
  // ─── Shared fixture ───────────────────────────────────────────────────────

  Map<String, dynamic> fullAnalyticsJson() => {
        'completionRate': 72,
        'totalTasks': 50,
        'completedTasks': 36,
        'overdueTasks': 4,
        'avgCompletionDays': 3.5,
        'tasksByPriority': [
          {'priority': 'HIGH', 'count': 15},
          {'priority': 'MEDIUM', 'count': 20},
          {'priority': 'LOW', 'count': 15},
        ],
        'tasksByStatus': [
          {'status': 'TODO', 'count': 10},
          {'status': 'IN_PROGRESS', 'count': 4},
          {'status': 'DONE', 'count': 36},
        ],
        'teamWorkload': [
          {
            'userId': 'user-001',
            'name': 'Alice',
            'avatarUrl': 'https://cdn.example.com/alice.png',
            'total': 12,
            'done': 8,
            'inProgress': 4,
          },
          {
            'userId': 'user-002',
            'name': 'Bob',
            'avatarUrl': null,
            'total': 10,
            'done': 6,
            'inProgress': 2,
          },
        ],
        'weeklyStats': [
          {
            'weekStart': '2025-05-05',
            'weekEnd': '2025-05-11',
            'created': 8,
            'completed': 5,
          },
          {
            'weekStart': '2025-05-12',
            'weekEnd': '2025-05-18',
            'created': 6,
            'completed': 7,
          },
        ],
      };

  // ─── Analytics.fromJson ───────────────────────────────────────────────────

  group('Analytics.fromJson', () {
    test('parses top-level numeric fields', () {
      final a = Analytics.fromJson(fullAnalyticsJson());

      expect(a.completionRate, 72);
      expect(a.totalTasks, 50);
      expect(a.completedTasks, 36);
      expect(a.overdueTasks, 4);
      expect(a.avgCompletionDays, 3.5);
    });

    test('parses tasksByPriority list', () {
      final a = Analytics.fromJson(fullAnalyticsJson());

      expect(a.tasksByPriority.length, 3);
      expect(a.tasksByPriority.first.priority, 'HIGH');
      expect(a.tasksByPriority.first.count, 15);
    });

    test('parses tasksByStatus list', () {
      final a = Analytics.fromJson(fullAnalyticsJson());

      expect(a.tasksByStatus.length, 3);
      expect(a.tasksByStatus[1].status, 'IN_PROGRESS');
      expect(a.tasksByStatus[1].count, 4);
    });

    test('parses teamWorkload list', () {
      final a = Analytics.fromJson(fullAnalyticsJson());

      expect(a.teamWorkload.length, 2);
      expect(a.teamWorkload.first.userId, 'user-001');
      expect(a.teamWorkload.first.name, 'Alice');
      expect(a.teamWorkload.first.total, 12);
      expect(a.teamWorkload.first.done, 8);
      expect(a.teamWorkload.first.inProgress, 4);
    });

    test('parses weeklyStats list', () {
      final a = Analytics.fromJson(fullAnalyticsJson());

      expect(a.weeklyStats.length, 2);
      expect(a.weeklyStats.first.weekStart, '2025-05-05');
      expect(a.weeklyStats.first.weekEnd, '2025-05-11');
      expect(a.weeklyStats.first.created, 8);
      expect(a.weeklyStats.first.completed, 5);
    });

    test('accepts snake_case field aliases', () {
      final json = {
        'completion_rate': 80,
        'total_tasks': 20,
        'completed_tasks': 16,
        'overdue_tasks': 2,
        'avg_completion_days': 2.0,
        'tasks_by_priority': <Map<String, dynamic>>[],
        'tasks_by_status': <Map<String, dynamic>>[],
        'team_workload': <Map<String, dynamic>>[],
        'weekly_stats': <Map<String, dynamic>>[],
      };

      final a = Analytics.fromJson(json);
      expect(a.completionRate, 80);
      expect(a.totalTasks, 20);
      expect(a.avgCompletionDays, 2.0);
    });

    test('defaults numeric fields to 0 when absent', () {
      final a = Analytics.fromJson({
        'tasksByPriority': <dynamic>[],
        'tasksByStatus': <dynamic>[],
        'teamWorkload': <dynamic>[],
        'weeklyStats': <dynamic>[],
      });

      expect(a.completionRate, 0);
      expect(a.totalTasks, 0);
      expect(a.completedTasks, 0);
      expect(a.overdueTasks, 0);
      expect(a.avgCompletionDays, 0.0);
    });

    test('empty lists default when nested keys absent', () {
      final a = Analytics.fromJson({});
      expect(a.tasksByPriority, isEmpty);
      expect(a.tasksByStatus, isEmpty);
      expect(a.teamWorkload, isEmpty);
      expect(a.weeklyStats, isEmpty);
    });
  });

  // ─── PriorityCount.fromJson ───────────────────────────────────────────────

  group('PriorityCount.fromJson', () {
    test('parses priority and count', () {
      final pc = PriorityCount.fromJson({'priority': 'CRITICAL', 'count': 3});
      expect(pc.priority, 'CRITICAL');
      expect(pc.count, 3);
    });

    test('defaults to empty string and 0 when fields absent', () {
      final pc = PriorityCount.fromJson({});
      expect(pc.priority, '');
      expect(pc.count, 0);
    });
  });

  // ─── StatusCount.fromJson ─────────────────────────────────────────────────

  group('StatusCount.fromJson', () {
    test('parses status and count', () {
      final sc = StatusCount.fromJson({'status': 'DONE', 'count': 25});
      expect(sc.status, 'DONE');
      expect(sc.count, 25);
    });

    test('defaults to empty string and 0 when fields absent', () {
      final sc = StatusCount.fromJson({});
      expect(sc.status, '');
      expect(sc.count, 0);
    });
  });

  // ─── TeamWorkload.fromJson ────────────────────────────────────────────────

  group('TeamWorkload.fromJson', () {
    test('parses all camelCase fields', () {
      final tw = TeamWorkload.fromJson({
        'userId': 'user-001',
        'name': 'Alice',
        'avatarUrl': 'https://cdn.example.com/alice.png',
        'total': 12,
        'done': 8,
        'inProgress': 4,
      });

      expect(tw.userId, 'user-001');
      expect(tw.name, 'Alice');
      expect(tw.avatarUrl, 'https://cdn.example.com/alice.png');
      expect(tw.total, 12);
      expect(tw.done, 8);
      expect(tw.inProgress, 4);
    });

    test('accepts snake_case field aliases', () {
      final tw = TeamWorkload.fromJson({
        'user_id': 'user-002',
        'name': 'Bob',
        'avatar_url': null,
        'total': 5,
        'done': 3,
        'in_progress': 2,
      });

      expect(tw.userId, 'user-002');
      expect(tw.avatarUrl, isNull);
      expect(tw.inProgress, 2);
    });

    test('avatarUrl is null when not provided', () {
      final tw = TeamWorkload.fromJson({
        'userId': 'user-003',
        'name': 'Charlie',
        'total': 0,
        'done': 0,
        'inProgress': 0,
      });
      expect(tw.avatarUrl, isNull);
    });

    test('defaults numeric fields to 0 when absent', () {
      final tw = TeamWorkload.fromJson({'userId': '', 'name': ''});
      expect(tw.total, 0);
      expect(tw.done, 0);
      expect(tw.inProgress, 0);
    });
  });

  // ─── WeeklyStats.fromJson ─────────────────────────────────────────────────

  group('WeeklyStats.fromJson', () {
    test('parses all camelCase fields', () {
      final ws = WeeklyStats.fromJson({
        'weekStart': '2025-05-05',
        'weekEnd': '2025-05-11',
        'created': 8,
        'completed': 5,
      });

      expect(ws.weekStart, '2025-05-05');
      expect(ws.weekEnd, '2025-05-11');
      expect(ws.created, 8);
      expect(ws.completed, 5);
    });

    test('accepts snake_case field aliases', () {
      final ws = WeeklyStats.fromJson({
        'week_start': '2025-04-28',
        'week_end': '2025-05-04',
        'created': 3,
        'completed': 6,
      });

      expect(ws.weekStart, '2025-04-28');
      expect(ws.weekEnd, '2025-05-04');
    });

    test('defaults to empty strings and 0 when fields absent', () {
      final ws = WeeklyStats.fromJson({});
      expect(ws.weekStart, '');
      expect(ws.weekEnd, '');
      expect(ws.created, 0);
      expect(ws.completed, 0);
    });
  });
}
