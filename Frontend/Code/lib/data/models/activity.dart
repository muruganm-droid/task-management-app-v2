class Activity {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String action;
  final String? details;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.action,
    this.details,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task_id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      userName:
          json['userName'] as String? ??
          json['user_name'] as String? ??
          'Unknown',
      action: json['action'] as String? ?? '',
      details: json['details'] as String?,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }
}
