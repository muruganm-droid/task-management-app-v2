class Project {
  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final bool isArchived;
  final int memberCount;
  final int taskCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.isArchived = false,
    this.memberCount = 1,
    this.taskCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String? ?? json['owner_id'] as String? ?? '',
      isArchived:
          json['isArchived'] as bool? ?? json['is_archived'] as bool? ?? false,
      memberCount:
          json['memberCount'] as int? ?? json['member_count'] as int? ?? 1,
      taskCount: json['taskCount'] as int? ?? json['task_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(
        json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      ) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(
        json['updatedAt'] as String? ?? json['updated_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}

class ProjectMember {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userAvatar;
  final ProjectRole role;
  final DateTime joinedAt;

  ProjectMember({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userAvatar,
    required this.role,
    required this.joinedAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      userName:
          json['userName'] as String? ?? json['user_name'] as String? ?? '',
      userEmail:
          json['userEmail'] as String? ?? json['user_email'] as String? ?? '',
      userAvatar:
          json['userAvatar'] as String? ?? json['user_avatar'] as String?,
      role: ProjectRole.fromString(json['role'] as String? ?? 'MEMBER'),
      joinedAt: DateTime.tryParse(
        json['joinedAt'] as String? ?? json['joined_at'] as String? ?? '',
      ) ?? DateTime.now(),
    );
  }
}

enum ProjectRole {
  owner,
  admin,
  member,
  viewer;

  static ProjectRole fromString(String value) {
    switch (value.toUpperCase()) {
      case 'OWNER':
        return ProjectRole.owner;
      case 'ADMIN':
        return ProjectRole.admin;
      case 'MEMBER':
        return ProjectRole.member;
      case 'VIEWER':
        return ProjectRole.viewer;
      default:
        return ProjectRole.member;
    }
  }

  String get apiValue {
    return name.toUpperCase();
  }

  String get displayName {
    switch (this) {
      case ProjectRole.owner:
        return 'Owner';
      case ProjectRole.admin:
        return 'Admin';
      case ProjectRole.member:
        return 'Member';
      case ProjectRole.viewer:
        return 'Viewer';
    }
  }
}
