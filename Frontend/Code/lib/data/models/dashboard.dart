import 'task.dart';

class DashboardMyTasks {
  final List<Task> tasks;
  final int totalCount;

  DashboardMyTasks({required this.tasks, required this.totalCount});

  factory DashboardMyTasks.fromJson(Map<String, dynamic> json) {
    return DashboardMyTasks(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount:
          json['totalCount'] as int? ?? json['total_count'] as int? ?? 0,
    );
  }
}

class ProjectDashboard {
  final Map<String, int> tasksByStatus;
  final Map<String, int> tasksByPriority;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;

  ProjectDashboard({
    required this.tasksByStatus,
    required this.tasksByPriority,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
  });

  factory ProjectDashboard.fromJson(Map<String, dynamic> json) {
    return ProjectDashboard(
      tasksByStatus:
          (json['tasksByStatus'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      tasksByPriority:
          (json['tasksByPriority'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      overdueTasks: json['overdueTasks'] as int? ?? 0,
    );
  }
}

class DashboardTrends {
  final List<TrendDataPoint> dataPoints;

  DashboardTrends({required this.dataPoints});

  factory DashboardTrends.fromJson(dynamic json) {
    if (json is List) {
      return DashboardTrends(
        dataPoints: json
            .map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    final map = json as Map<String, dynamic>;
    return DashboardTrends(
      dataPoints:
          (map['data'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TrendDataPoint {
  final String date;
  final int created;
  final int completed;

  TrendDataPoint({
    required this.date,
    required this.created,
    required this.completed,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] as String? ?? '',
      created: json['created'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
    );
  }
}
