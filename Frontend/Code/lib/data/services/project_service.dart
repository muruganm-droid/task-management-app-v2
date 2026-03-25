import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/project.dart';
import '../models/label.dart';

class ProjectService {
  final ApiClient _apiClient;

  ProjectService(this._apiClient);

  Future<List<Project>> listProjects() async {
    try {
      final response = await _apiClient.dio.get('/projects');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Project.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Project> createProject({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/projects',
        data: {'name': name, 'description': description},
      );
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Project> getProject(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/projects/$projectId');
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Project> updateProject(
    String projectId, {
    String? name,
    String? description,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final response = await _apiClient.dio.put(
        '/projects/$projectId',
        data: data,
      );
      return Project.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _apiClient.dio.delete('/projects/$projectId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Members
  Future<List<ProjectMember>> listMembers(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/projects/$projectId/members');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => ProjectMember.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProjectMember> addMember(
    String projectId, {
    required String email,
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/projects/$projectId/members',
        data: {'email': email, 'role': role},
      );
      return ProjectMember.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<ProjectMember> updateMemberRole(
    String projectId,
    String userId, {
    required String role,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/projects/$projectId/members/$userId',
        data: {'role': role},
      );
      return ProjectMember.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _apiClient.dio.delete('/projects/$projectId/members/$userId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Labels
  Future<List<Label>> listLabels(String projectId) async {
    try {
      final response = await _apiClient.dio.get('/projects/$projectId/labels');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Label.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Label> createLabel(
    String projectId, {
    required String name,
    required String color,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/projects/$projectId/labels',
        data: {'name': name, 'color': color},
      );
      return Label.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
