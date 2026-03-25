class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? link;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.link,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? 'TASK_ASSIGNED'),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      link: json['link'] as String?,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      link: link,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

enum NotificationType {
  taskAssigned('TASK_ASSIGNED'),
  dueSoon('DUE_SOON'),
  commentAdded('COMMENT_ADDED');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TASK_ASSIGNED':
        return NotificationType.taskAssigned;
      case 'DUE_SOON':
        return NotificationType.dueSoon;
      case 'COMMENT_ADDED':
        return NotificationType.commentAdded;
      default:
        return NotificationType.taskAssigned;
    }
  }
}
