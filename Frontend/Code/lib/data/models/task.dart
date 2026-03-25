import 'attachment.dart';

class Task {
  final String id;
  final String projectId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final String creatorId;
  final List<String> assigneeIds;
  final List<String> labelIds;
  final List<SubTask> subTasks;
  final int position;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.creatorId,
    this.assigneeIds = const [],
    this.labelIds = const [],
    this.subTasks = const [],
    this.position = 0,
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? json['project_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: TaskStatus.fromString(json['status'] as String? ?? 'TODO'),
      priority: TaskPriority.fromString(json['priority'] as String? ?? 'MEDIUM'),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      creatorId:
          json['creatorId'] as String? ?? json['creator_id'] as String? ?? '',
      assigneeIds:
          (json['assigneeIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['assignee_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      labelIds:
          (json['labelIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['label_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      subTasks:
          (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['sub_tasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      position: json['position'] as int? ?? 0,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(
        json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.value,
      'priority': priority.value,
      'dueDate': dueDate?.toIso8601String(),
      'assigneeIds': assigneeIds,
      'position': position,
    };
  }

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? assigneeIds,
    List<String>? labelIds,
    List<SubTask>? subTasks,
    int? position,
    List<Attachment>? attachments,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      creatorId: creatorId,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      labelIds: labelIds ?? this.labelIds,
      subTasks: subTasks ?? this.subTasks,
      position: position ?? this.position,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.done &&
      status != TaskStatus.archived;

  int get completedSubTaskCount => subTasks.where((s) => s.isDone).length;
}

class SubTask {
  final String id;
  final String taskId;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  SubTask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String? ?? '',
      taskId: json['taskId'] as String? ?? json['task_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? json['is_done'] as bool? ?? false,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isDone': isDone};
  }

  SubTask copyWith({String? title, bool? isDone}) {
    return SubTask(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
    );
  }
}

enum TaskStatus {
  todo('TODO', 'To Do'),
  inProgress('IN_PROGRESS', 'In Progress'),
  underReview('UNDER_REVIEW', 'Under Review'),
  done('DONE', 'Done'),
  archived('ARCHIVED', 'Archived');

  final String value;
  final String displayName;

  const TaskStatus(this.value, this.displayName);

  static TaskStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TODO':
        return TaskStatus.todo;
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'UNDER_REVIEW':
        return TaskStatus.underReview;
      case 'DONE':
        return TaskStatus.done;
      case 'ARCHIVED':
        return TaskStatus.archived;
      default:
        return TaskStatus.todo;
    }
  }
}

enum TaskPriority {
  low('LOW', 'Low'),
  medium('MEDIUM', 'Medium'),
  high('HIGH', 'High'),
  critical('CRITICAL', 'Critical');

  final String value;
  final String displayName;

  const TaskPriority(this.value, this.displayName);

  static TaskPriority fromString(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'MEDIUM':
        return TaskPriority.medium;
      case 'HIGH':
        return TaskPriority.high;
      case 'CRITICAL':
        return TaskPriority.critical;
      default:
        return TaskPriority.medium;
    }
  }
}
