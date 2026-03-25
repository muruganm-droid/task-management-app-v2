import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/user.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/auth_response.dart';
import 'package:task_management_app/domain/repositories/auth_repository.dart';
import 'package:task_management_app/domain/repositories/task_repository.dart';
import 'package:task_management_app/domain/repositories/project_repository.dart';
import 'package:task_management_app/domain/repositories/notification_repository.dart';
import 'package:task_management_app/domain/repositories/comment_repository.dart';
import 'package:task_management_app/domain/repositories/dashboard_repository.dart';
// --- Mocks ---
class MockAuthRepository extends Mock implements AuthRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class MockCommentRepository extends Mock implements CommentRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

// --- Factory data ---
User createTestUser({
  String id = 'user-1',
  String email = 'test@example.com',
  String name = 'Test User',
  String? bio,
}) {
  return User(
    id: id,
    email: email,
    name: name,
    bio: bio,
    createdAt: DateTime(2024, 1, 1),
  );
}

Task createTestTask({
  String id = 'task-1',
  String projectId = 'proj-1',
  String title = 'Test Task',
  String? description,
  TaskStatus status = TaskStatus.todo,
  TaskPriority priority = TaskPriority.medium,
  DateTime? dueDate,
  List<SubTask> subTasks = const [],
  List<String> assigneeIds = const [],
}) {
  return Task(
    id: id,
    projectId: projectId,
    title: title,
    description: description,
    status: status,
    priority: priority,
    dueDate: dueDate,
    creatorId: 'user-1',
    assigneeIds: assigneeIds,
    subTasks: subTasks,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

SubTask createTestSubTask({
  String id = 'sub-1',
  String taskId = 'task-1',
  String title = 'Sub task 1',
  bool isDone = false,
}) {
  return SubTask(
    id: id,
    taskId: taskId,
    title: title,
    isDone: isDone,
    createdAt: DateTime(2024, 1, 1),
  );
}

Project createTestProject({
  String id = 'proj-1',
  String name = 'Test Project',
  String? description,
  int memberCount = 3,
  int taskCount = 10,
  bool isArchived = false,
}) {
  return Project(
    id: id,
    name: name,
    description: description,
    ownerId: 'user-1',
    isArchived: isArchived,
    memberCount: memberCount,
    taskCount: taskCount,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

AppNotification createTestNotification({
  String id = 'notif-1',
  NotificationType type = NotificationType.taskAssigned,
  String title = 'New assignment',
  String body = 'You were assigned a task',
  bool isRead = false,
}) {
  return AppNotification(
    id: id,
    userId: 'user-1',
    type: type,
    title: title,
    body: body,
    isRead: isRead,
    createdAt: DateTime(2024, 1, 1),
  );
}

Comment createTestComment({
  String id = 'comment-1',
  String taskId = 'task-1',
  String body = 'A test comment',
  String authorName = 'Test User',
}) {
  return Comment(
    id: id,
    taskId: taskId,
    authorId: 'user-1',
    authorName: authorName,
    body: body,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );
}

AuthResponse createTestAuthResponse() {
  return AuthResponse(
    user: createTestUser(),
    tokens: AuthTokens(
      accessToken: 'test-access-token',
      refreshToken: 'test-refresh-token',
    ),
  );
}

// --- Wrappers ---
Future<SharedPreferences> createTestPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Widget createTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

Widget createTestAppWithTheme({
  required Widget child,
  required ThemeData theme,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: theme,
      home: child,
    ),
  );
}

/// Pumps widgets with settling for animations
Future<void> pumpAndSettle(WidgetTester tester, {int? seconds}) async {
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    Duration(seconds: seconds ?? 10),
  );
}
