import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/analytics.dart';
import '../models/dashboard.dart';
import '../models/task.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<List<Task>> getMyTasks() async {
    try {
      final response = await _apiClient.dio.get('/dashboard/my-tasks');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic> && data['tasks'] != null) {
        return (data['tasks'] as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProjectDashboard> getProjectDashboard(String projectId) async {
    try {
      final response = await _apiClient.dio.get(
        '/dashboard/projects/$projectId',
      );
      return ProjectDashboard.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<DashboardTrends> getTrends() async {
    try {
      final response = await _apiClient.dio.get('/dashboard/trends');
      return DashboardTrends.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Analytics> getAnalytics() async {
    try {
      final response = await _apiClient.dio.get('/dashboard/analytics');
      return Analytics.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
