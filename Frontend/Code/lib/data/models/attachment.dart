class Attachment {
  final String id;
  final String taskId;
  final String uploaderId;
  final String fileName;
  final String fileUrl;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.taskId,
    required this.uploaderId,
    required this.fileName,
    required this.fileUrl,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task_id'] as String? ?? '',
      uploaderId:
          json['uploaderId'] as String? ??
          json['uploader_id'] as String? ??
          '',
      fileName:
          json['fileName'] as String? ?? json['file_name'] as String? ?? '',
      fileUrl: json['fileUrl'] as String? ?? json['file_url'] as String? ?? '',
      mimeType:
          json['mimeType'] as String? ?? json['mime_type'] as String? ?? '',
      fileSize:
          json['fileSize'] as int? ?? json['file_size'] as int? ?? 0,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'uploaderId': uploaderId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isImage => mimeType.startsWith('image/');
}
