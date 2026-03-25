import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/task.dart';
import '../models/activity.dart';

class TaskService {
  final ApiClient _apiClient;

  TaskService(this._apiClient);

  // Tasks by project
  Future<List<Task>> listProjectTasks(
    String projectId, {
    String? status,
    String? priority,
    String? assigneeId,
    String? labelId,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (assigneeId != null) queryParams['assigneeId'] = assigneeId;
      if (labelId != null) queryParams['labelId'] = labelId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final response = await _apiClient.dio.get(
        '/projects/$projectId/tasks',
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Task> createTask(
    String projectId, {
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    List<String>? assigneeIds,
  }) async {
    try {
      final data = <String, dynamic>{'title': title};
      if (description != null) data['description'] = description;
      if (priority != null) data['priority'] = priority;
      if (dueDate != null) data['dueDate'] = dueDate;
      if (assigneeIds != null) data['assigneeIds'] = assigneeIds;

      final response = await _apiClient.dio.post(
        '/projects/$projectId/tasks',
        data: data,
      );
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Single task operations
  Future<Task> getTask(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$taskId');
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? status,
    String? priority,
    String? description,
    String? dueDate,
    List<String>? assigneeIds,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (status != null) data['status'] = status;
      if (priority != null) data['priority'] = priority;
      if (description != null) data['description'] = description;
      if (dueDate != null) data['dueDate'] = dueDate;
      if (assigneeIds != null) data['assigneeIds'] = assigneeIds;

      final response = await _apiClient.dio.put('/tasks/$taskId', data: data);
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _apiClient.dio.delete('/tasks/$taskId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Subtasks
  Future<List<SubTask>> listSubtasks(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$taskId/subtasks');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => SubTask.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SubTask> createSubtask(String taskId, {required String title}) async {
    try {
      final response = await _apiClient.dio.post(
        '/tasks/$taskId/subtasks',
        data: {'title': title},
      );
      return SubTask.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SubTask> updateSubtask(
    String taskId,
    String subtaskId, {
    String? title,
    bool? isDone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (isDone != null) data['isDone'] = isDone;

      final response = await _apiClient.dio.put(
        '/tasks/$taskId/subtasks/$subtaskId',
        data: data,
      );
      return SubTask.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    try {
      await _apiClient.dio.delete('/tasks/$taskId/subtasks/$subtaskId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Labels on tasks
  Future<void> attachLabels(String taskId, List<String> labelIds) async {
    try {
      await _apiClient.dio.post(
        '/tasks/$taskId/labels',
        data: {'labelIds': labelIds},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> removeLabel(String taskId, String labelId) async {
    try {
      await _apiClient.dio.delete('/tasks/$taskId/labels/$labelId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Bulk and reorder operations
  Future<void> bulkUpdateStatus(List<String> taskIds, String status) async {
    try {
      await _apiClient.dio.put(
        '/tasks/bulk-status',
        data: {'taskIds': taskIds, 'status': status},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Task> reorderTask(
    String taskId,
    String newStatus,
    int newPosition,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        '/tasks/reorder',
        data: {
          'taskId': taskId,
          'newStatus': newStatus,
          'newPosition': newPosition,
        },
      );
      return Task.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Activity
  Future<List<Activity>> getActivity(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$taskId/activity');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Activity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
