import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/search_result.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService(this._apiClient);

  Future<SearchResult> search({
    String? q,
    String? type,
    String? status,
    String? priority,
    String? assigneeId,
    String? dueBefore,
    String? dueAfter,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (assigneeId != null) queryParams['assigneeId'] = assigneeId;
      if (dueBefore != null) queryParams['dueBefore'] = dueBefore;
      if (dueAfter != null) queryParams['dueAfter'] = dueAfter;

      final response = await _apiClient.dio.get(
        '/search',
        queryParameters: queryParams,
      );
      return SearchResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
