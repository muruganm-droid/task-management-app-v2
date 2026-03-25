class Comment {
  final String id;
  final String taskId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String body;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.body,
    this.isEdited = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task_id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? json['author_id'] as String? ?? '',
      authorName:
          json['authorName'] as String? ??
          json['author_name'] as String? ??
          'Unknown',
      authorAvatar:
          json['authorAvatar'] as String? ?? json['author_avatar'] as String?,
      body: json['body'] as String? ?? '',
      isEdited:
          json['isEdited'] as bool? ?? json['is_edited'] as bool? ?? false,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(
        json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'body': body};
  }
}
