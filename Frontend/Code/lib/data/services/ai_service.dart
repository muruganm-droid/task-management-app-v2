import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';

class AiService {
  final ApiClient _apiClient;

  AiService(this._apiClient);

  Future<Map<String, dynamic>> parseTask(
    String transcript,
    String projectId,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/ai/parse-task',
        data: {'transcript': transcript, 'projectId': projectId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
