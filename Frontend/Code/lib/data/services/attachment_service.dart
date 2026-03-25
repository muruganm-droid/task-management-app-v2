import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/attachment.dart';

class AttachmentService {
  final ApiClient _apiClient;

  AttachmentService(this._apiClient);

  Future<List<Attachment>> listAttachments(String taskId) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$taskId/attachments');
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Attachment> uploadAttachment(
    String taskId,
    String filePath,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _apiClient.dio.post(
        '/tasks/$taskId/attachments',
        data: formData,
      );
      return Attachment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteAttachment(String attachmentId) async {
    try {
      await _apiClient.dio.delete('/attachments/$attachmentId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
