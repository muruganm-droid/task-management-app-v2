import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/comment.dart';

class CommentService {
  final ApiClient _apiClient;

  CommentService(this._apiClient);

  Future<List<Comment>> listComments(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$taskId/comments');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Comment> addComment(String taskId, {required String body}) async {
    try {
      final response = await _apiClient.dio.post(
        '/tasks/$taskId/comments',
        data: {'body': body},
      );
      return Comment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Comment> updateComment(
    String commentId, {
    required String body,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/comments/$commentId',
        data: {'body': body},
      );
      return Comment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _apiClient.dio.delete('/comments/$commentId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
