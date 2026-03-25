class Analytics {
  final int completionRate;
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final double avgCompletionDays;
  final List<PriorityCount> tasksByPriority;
  final List<StatusCount> tasksByStatus;
  final List<TeamWorkload> teamWorkload;
  final List<WeeklyStats> weeklyStats;

  Analytics({
    required this.completionRate,
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.avgCompletionDays,
    required this.tasksByPriority,
    required this.tasksByStatus,
    required this.teamWorkload,
    required this.weeklyStats,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      completionRate:
          json['completionRate'] as int? ??
          json['completion_rate'] as int? ??
          0,
      totalTasks:
          json['totalTasks'] as int? ?? json['total_tasks'] as int? ?? 0,
      completedTasks:
          json['completedTasks'] as int? ??
          json['completed_tasks'] as int? ??
          0,
      overdueTasks:
          json['overdueTasks'] as int? ?? json['overdue_tasks'] as int? ?? 0,
      avgCompletionDays:
          (json['avgCompletionDays'] as num? ??
                  json['avg_completion_days'] as num? ??
                  0)
              .toDouble(),
      tasksByPriority:
          (json['tasksByPriority'] as List<dynamic>? ??
                  json['tasks_by_priority'] as List<dynamic>? ??
                  [])
              .map((e) => PriorityCount.fromJson(e as Map<String, dynamic>))
              .toList(),
      tasksByStatus:
          (json['tasksByStatus'] as List<dynamic>? ??
                  json['tasks_by_status'] as List<dynamic>? ??
                  [])
              .map((e) => StatusCount.fromJson(e as Map<String, dynamic>))
              .toList(),
      teamWorkload:
          (json['teamWorkload'] as List<dynamic>? ??
                  json['team_workload'] as List<dynamic>? ??
                  [])
              .map((e) => TeamWorkload.fromJson(e as Map<String, dynamic>))
              .toList(),
      weeklyStats:
          (json['weeklyStats'] as List<dynamic>? ??
                  json['weekly_stats'] as List<dynamic>? ??
                  [])
              .map((e) => WeeklyStats.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}

class PriorityCount {
  final String priority;
  final int count;

  PriorityCount({required this.priority, required this.count});

  factory PriorityCount.fromJson(Map<String, dynamic> json) {
    return PriorityCount(
      priority: json['priority'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class StatusCount {
  final String status;
  final int count;

  StatusCount({required this.status, required this.count});

  factory StatusCount.fromJson(Map<String, dynamic> json) {
    return StatusCount(
      status: json['status'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class TeamWorkload {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int total;
  final int done;
  final int inProgress;

  TeamWorkload({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.total,
    required this.done,
    required this.inProgress,
  });

  factory TeamWorkload.fromJson(Map<String, dynamic> json) {
    return TeamWorkload(
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarUrl:
          json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      total: json['total'] as int? ?? 0,
      done: json['done'] as int? ?? 0,
      inProgress:
          json['inProgress'] as int? ?? json['in_progress'] as int? ?? 0,
    );
  }
}

class WeeklyStats {
  final String weekStart;
  final String weekEnd;
  final int created;
  final int completed;

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.created,
    required this.completed,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      weekStart:
          json['weekStart'] as String? ?? json['week_start'] as String? ?? '',
      weekEnd: json['weekEnd'] as String? ?? json['week_end'] as String? ?? '',
      created: json['created'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
    );
  }
}
