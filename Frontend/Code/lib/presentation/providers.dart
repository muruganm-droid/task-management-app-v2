import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/api/api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/project_service.dart';
import '../data/services/task_service.dart';
import '../data/services/comment_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/dashboard_service.dart';
import '../data/services/search_service.dart';
import '../data/services/attachment_service.dart';
import '../data/services/ai_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/project_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/comment_repository_impl.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/comment_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/dashboard_repository.dart';

// Core
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('Must be overridden in main with a pre-initialized ApiClient');
});

// Services
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService(ref.watch(apiClientProvider));
});

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.watch(apiClientProvider));
});

final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService(ref.watch(apiClientProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(apiClientProvider));
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.watch(apiClientProvider));
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(ref.watch(apiClientProvider));
});

final attachmentServiceProvider = Provider<AttachmentService>((ref) {
  return AttachmentService(ref.watch(apiClientProvider));
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(apiClientProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authServiceProvider),
    ref.watch(apiClientProvider),
  );
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepositoryImpl(ref.watch(projectServiceProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskServiceProvider));
});

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepositoryImpl(ref.watch(commentServiceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationServiceProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardServiceProvider));
});
