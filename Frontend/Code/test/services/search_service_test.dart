import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_management_app/data/api/api_client.dart';
import 'package:task_management_app/data/services/search_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

// ─── Stub Responses ──────────────────────────────────────────────────────────

/// Returns a minimal SearchResult-shaped response (empty tasks and projects).
Response<dynamic> _emptySearchResponse() {
  return Response(
    data: {'tasks': [], 'projects': []},
    statusCode: 200,
    requestOptions: RequestOptions(path: '/search'),
  );
}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late SearchService searchService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();

    // Wire the mock ApiClient so that .dio returns the mock Dio instance.
    when(() => mockApiClient.dio).thenReturn(mockDio);

    searchService = SearchService(mockApiClient);
  });

  // ─── Query parameter construction ─────────────────────────────────────────

  group('SearchService.search – query parameter construction', () {
    test('sends q parameter when query string is provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'q': 'login bug'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(q: 'login bug');

      verify(
        () => mockDio.get(
          '/search',
          queryParameters: {'q': 'login bug'},
        ),
      ).called(1);
    });

    test('does NOT include q when query string is empty', () async {
      when(
        () => mockDio.get('/search', queryParameters: {}),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(q: '');

      verify(
        () => mockDio.get('/search', queryParameters: {}),
      ).called(1);
    });

    test('does NOT include q when query string is null', () async {
      when(
        () => mockDio.get('/search', queryParameters: {}),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search();

      verify(
        () => mockDio.get('/search', queryParameters: {}),
      ).called(1);
    });

    test('sends type parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'type': 'task'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(type: 'task');

      verify(
        () => mockDio.get('/search', queryParameters: {'type': 'task'}),
      ).called(1);
    });

    test('sends status parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'status': 'TODO'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(status: 'TODO');

      verify(
        () => mockDio.get('/search', queryParameters: {'status': 'TODO'}),
      ).called(1);
    });

    test('sends priority parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'priority': 'HIGH'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(priority: 'HIGH');

      verify(
        () => mockDio.get('/search', queryParameters: {'priority': 'HIGH'}),
      ).called(1);
    });

    test('sends assigneeId parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'assigneeId': 'user-007'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(assigneeId: 'user-007');

      verify(
        () =>
            mockDio.get('/search', queryParameters: {'assigneeId': 'user-007'}),
      ).called(1);
    });

    test('sends dueBefore parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'dueBefore': '2025-12-31'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(dueBefore: '2025-12-31');

      verify(
        () => mockDio.get(
          '/search',
          queryParameters: {'dueBefore': '2025-12-31'},
        ),
      ).called(1);
    });

    test('sends dueAfter parameter when provided', () async {
      when(
        () => mockDio.get(
          '/search',
          queryParameters: {'dueAfter': '2025-01-01'},
        ),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(dueAfter: '2025-01-01');

      verify(
        () => mockDio.get(
          '/search',
          queryParameters: {'dueAfter': '2025-01-01'},
        ),
      ).called(1);
    });

    test('combines multiple parameters correctly', () async {
      final expectedParams = {
        'q': 'deploy',
        'type': 'task',
        'status': 'IN_PROGRESS',
        'priority': 'HIGH',
        'assigneeId': 'user-001',
        'dueBefore': '2025-12-31',
        'dueAfter': '2025-06-01',
      };

      when(
        () => mockDio.get('/search', queryParameters: expectedParams),
      ).thenAnswer((_) async => _emptySearchResponse());

      await searchService.search(
        q: 'deploy',
        type: 'task',
        status: 'IN_PROGRESS',
        priority: 'HIGH',
        assigneeId: 'user-001',
        dueBefore: '2025-12-31',
        dueAfter: '2025-06-01',
      );

      verify(
        () => mockDio.get('/search', queryParameters: expectedParams),
      ).called(1);
    });

    test('returns a SearchResult parsed from response data', () async {
      when(
        () => mockDio.get('/search', queryParameters: {'q': 'alpha'}),
      ).thenAnswer((_) async => Response(
            data: {
              'tasks': [
                {
                  'id': 'task-001',
                  'projectId': 'proj-001',
                  'title': 'Alpha task',
                  'status': 'TODO',
                  'priority': 'MEDIUM',
                  'creatorId': 'user-001',
                  'assigneeIds': <String>[],
                  'labelIds': <String>[],
                  'subTasks': <Map<String, dynamic>>[],
                  'position': 0,
                  'attachments': <Map<String, dynamic>>[],
                  'createdAt': '2025-01-01T00:00:00.000Z',
                  'updatedAt': '2025-01-01T00:00:00.000Z',
                }
              ],
              'projects': [],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: '/search'),
          ));

      final result = await searchService.search(q: 'alpha');

      expect(result.tasks.length, 1);
      expect(result.tasks.first.id, 'task-001');
      expect(result.tasks.first.title, 'Alpha task');
      expect(result.projects, isEmpty);
    });

    test('throws ApiException on DioException', () async {
      when(
        () => mockDio.get('/search', queryParameters: {'q': 'fail'}),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/search'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => searchService.search(q: 'fail'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
