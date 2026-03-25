// =============================================================================
// Category 8 Extended: Security Tests
// NEW tests: path traversal in URLs, XSS in task fields, JWT format validation,
// HTML injection in comments, SQL injection in project names, input sanitization
// edge cases, auth token handling, model field boundary attacks, URL injection
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/api/api_config.dart';
import 'package:task_management_app/data/models/task.dart';
import 'package:task_management_app/data/models/project.dart';
import 'package:task_management_app/data/models/user.dart';
import 'package:task_management_app/data/models/comment.dart';
import 'package:task_management_app/data/models/notification.dart';
import 'package:task_management_app/data/models/attachment.dart';
import 'package:task_management_app/data/models/label.dart';
import 'package:task_management_app/presentation/viewmodels/auth_viewmodel.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('SEC-EXT-001: XSS in task fields', () {
    test('Script tag in task title stored as text', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': '<script>document.cookie</script>',
        'status': 'TODO',
        'priority': 'HIGH',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.title, '<script>document.cookie</script>');
    });

    test('JavaScript URL in task description stored as text', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task',
        'description': 'javascript:alert(1)',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.description, 'javascript:alert(1)');
    });

    test('Event handler injection in title', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': '" onmouseover="alert(1)"',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      // Flutter Text widget renders this as plain text
      expect(task.title, contains('onmouseover'));
    });
  });

  group('SEC-EXT-002: SQL injection in model fields', () {
    test('SQL injection in project name stored as text', () {
      final project = Project.fromJson({
        'id': 'p-1',
        'name': "'; DROP TABLE projects; --",
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(project.name, "'; DROP TABLE projects; --");
    });

    test('SQL injection in user name', () {
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'test@test.com',
        'name': "Robert'); DROP TABLE users;--",
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.name, "Robert'); DROP TABLE users;--");
    });
  });

  group('SEC-EXT-003: HTML injection in comments', () {
    test('HTML in comment body stored as text', () {
      final comment = Comment.fromJson({
        'id': 'c-1',
        'taskId': 't-1',
        'authorId': 'u-1',
        'authorName': 'User',
        'body': '<div onload="fetch(\'evil.com\')">Click</div>',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(comment.body, contains('<div'));
    });

    test('Iframe injection in comment', () {
      final comment = Comment.fromJson({
        'id': 'c-2',
        'body': '<iframe src="evil.com"></iframe>',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(comment.body, contains('iframe'));
    });
  });

  group('SEC-EXT-004: URL injection in attachment fields', () {
    test('Malicious file URL in attachment', () {
      final a = Attachment.fromJson({
        'id': 'a-1',
        'fileUrl': 'javascript:alert(document.domain)',
        'fileName': 'exploit.html',
        'mimeType': 'text/html',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.fileUrl, 'javascript:alert(document.domain)');
    });

    test('Path traversal in fileName', () {
      final a = Attachment.fromJson({
        'id': 'a-2',
        'fileName': '../../../etc/passwd',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(a.fileName, '../../../etc/passwd');
    });
  });

  group('SEC-EXT-005: JWT token format validation', () {
    test('Valid JWT-like token has 3 parts', () {
      const token = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyLTEifQ.sig';
      final parts = token.split('.');
      expect(parts.length, 3);
    });

    test('Empty token is not valid JWT', () {
      const token = '';
      expect(token.isEmpty, true);
      expect(token.split('.').length, lessThan(3));
    });

    test('Malformed token without dots', () {
      const token = 'notavalidtoken';
      expect(token.split('.').length, 1);
    });
  });

  group('SEC-EXT-006: Auth state does not persist sensitive data in error', () {
    test('Error message should not contain password', () {
      const state = AuthState(error: 'Invalid credentials');
      expect(state.error, isNot(contains('password')));
    });

    test('clearError removes error', () {
      const state = AuthState(error: 'Some error');
      final cleared = state.copyWith(clearError: true);
      expect(cleared.error, isNull);
    });
  });

  group('SEC-EXT-007: API URL validation', () {
    test('All environments use HTTPS or localhost', () {
      for (final env in Environment.values) {
        ApiConfig.setEnvironment(env);
        final url = ApiConfig.baseUrl;
        expect(
          url.startsWith('https://') || url.startsWith('http://localhost'),
          true,
          reason: '$env environment URL must use HTTPS or localhost',
        );
      }
    });

    test('Base URL does not contain credentials', () {
      for (final env in Environment.values) {
        ApiConfig.setEnvironment(env);
        final url = ApiConfig.baseUrl;
        expect(url.contains('@'), false,
            reason: 'URL should not embed credentials');
        expect(url.contains('password'), false);
      }
    });
  });

  group('SEC-EXT-008: Null byte injection', () {
    test('Null byte in task title', () {
      final task = Task.fromJson({
        'id': 't-1',
        'title': 'Task\x00Injected',
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      // Dart strings can contain null bytes
      expect(task.title, isNotEmpty);
    });
  });

  group('SEC-EXT-009: Extremely long input handling', () {
    test('Very long task title does not crash model', () {
      final longTitle = 'A' * 10000;
      final task = Task.fromJson({
        'id': 't-1',
        'title': longTitle,
        'status': 'TODO',
        'priority': 'MEDIUM',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(task.title.length, 10000);
    });

    test('Very long comment body does not crash', () {
      final longBody = 'X' * 50000;
      final comment = Comment.fromJson({
        'id': 'c-1',
        'body': longBody,
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      });
      expect(comment.body.length, 50000);
    });

    test('Very long user name does not crash', () {
      final longName = 'B' * 5000;
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'test@test.com',
        'name': longName,
        'createdAt': '2024-01-01T00:00:00Z',
      });
      expect(user.name.length, 5000);
    });
  });

  group('SEC-EXT-010: Label color injection', () {
    test('Label with valid hex color', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'name': 'Test',
        'color': '#FF0000',
      });
      expect(l.colorHex, '#FF0000');
    });

    test('Label with missing color uses default gray', () {
      final l = Label.fromJson({
        'id': 'l-1',
        'name': 'Test',
      });
      expect(l.colorHex, '#6B7280');
    });
  });

  group('SEC-EXT-011: Notification link validation', () {
    test('Notification with javascript: link stored as-is', () {
      final n = AppNotification.fromJson({
        'id': 'n-1',
        'type': 'TASK_ASSIGNED',
        'title': 'Assigned',
        'body': 'You were assigned',
        'link': 'javascript:alert(1)',
        'createdAt': '2024-01-01T00:00:00Z',
      });
      // Model stores it; UI must validate before navigating
      expect(n.link, 'javascript:alert(1)');
    });
  });

  group('SEC-EXT-012: XSS in widget rendering', () {
    testWidgets('Script tag in task title renders as text', (tester) async {
      final task = createTestTask(title: '<script>alert("xss")</script>');
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Text(task.title),
        ),
      ));
      // Flutter Text widget does NOT execute HTML
      expect(find.text('<script>alert("xss")</script>'), findsOneWidget);
    });
  });
}
