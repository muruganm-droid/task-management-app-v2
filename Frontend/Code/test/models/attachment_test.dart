import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/data/models/attachment.dart';

void main() {
  // ─── Shared fixture ───────────────────────────────────────────────────────

  Map<String, dynamic> _baseJson() => {
        'id': 'att-001',
        'taskId': 'task-001',
        'uploaderId': 'user-001',
        'fileName': 'photo.jpg',
        'fileUrl': 'https://cdn.example.com/photo.jpg',
        'mimeType': 'image/jpeg',
        'fileSize': 512000,
        'createdAt': '2025-04-15T08:30:00.000Z',
      };

  // ─── Attachment.fromJson ──────────────────────────────────────────────────

  group('Attachment.fromJson', () {
    test('parses all camelCase fields', () {
      final att = Attachment.fromJson(_baseJson());

      expect(att.id, 'att-001');
      expect(att.taskId, 'task-001');
      expect(att.uploaderId, 'user-001');
      expect(att.fileName, 'photo.jpg');
      expect(att.fileUrl, 'https://cdn.example.com/photo.jpg');
      expect(att.mimeType, 'image/jpeg');
      expect(att.fileSize, 512000);
      expect(att.createdAt, DateTime.parse('2025-04-15T08:30:00.000Z'));
    });

    test('accepts snake_case field aliases', () {
      final json = {
        'id': 'att-002',
        'task_id': 'task-002',
        'uploader_id': 'user-002',
        'file_name': 'report.pdf',
        'file_url': 'https://cdn.example.com/report.pdf',
        'mime_type': 'application/pdf',
        'file_size': 1024,
        'created_at': '2025-05-01T00:00:00.000Z',
      };

      final att = Attachment.fromJson(json);

      expect(att.taskId, 'task-002');
      expect(att.uploaderId, 'user-002');
      expect(att.fileName, 'report.pdf');
      expect(att.fileUrl, 'https://cdn.example.com/report.pdf');
      expect(att.mimeType, 'application/pdf');
      expect(att.fileSize, 1024);
    });

    test('fileName defaults to empty string when absent', () {
      final json = Map<String, dynamic>.from(_baseJson())..remove('fileName');
      final att = Attachment.fromJson(json);
      expect(att.fileName, '');
    });

    test('fileSize defaults to 0 when absent', () {
      final json = Map<String, dynamic>.from(_baseJson())..remove('fileSize');
      final att = Attachment.fromJson(json);
      expect(att.fileSize, 0);
    });

    test('mimeType defaults to empty string when absent', () {
      final json = Map<String, dynamic>.from(_baseJson())..remove('mimeType');
      final att = Attachment.fromJson(json);
      expect(att.mimeType, '');
    });

    test('fileUrl defaults to empty string when absent', () {
      final json = Map<String, dynamic>.from(_baseJson())..remove('fileUrl');
      final att = Attachment.fromJson(json);
      expect(att.fileUrl, '');
    });
  });

  // ─── Attachment.isImage ───────────────────────────────────────────────────

  group('Attachment.isImage', () {
    Attachment _makeWith(String mimeType) => Attachment(
          id: 'att-x',
          taskId: 'task-x',
          uploaderId: 'user-x',
          fileName: 'file',
          fileUrl: 'https://cdn.example.com/file',
          mimeType: mimeType,
          fileSize: 1,
          createdAt: DateTime(2025, 1, 1),
        );

    test('returns true for image/jpeg', () {
      expect(_makeWith('image/jpeg').isImage, isTrue);
    });

    test('returns true for image/png', () {
      expect(_makeWith('image/png').isImage, isTrue);
    });

    test('returns true for image/gif', () {
      expect(_makeWith('image/gif').isImage, isTrue);
    });

    test('returns true for image/webp', () {
      expect(_makeWith('image/webp').isImage, isTrue);
    });

    test('returns true for image/svg+xml', () {
      expect(_makeWith('image/svg+xml').isImage, isTrue);
    });

    test('returns false for application/pdf', () {
      expect(_makeWith('application/pdf').isImage, isFalse);
    });

    test('returns false for video/mp4', () {
      expect(_makeWith('video/mp4').isImage, isFalse);
    });

    test('returns false for text/plain', () {
      expect(_makeWith('text/plain').isImage, isFalse);
    });

    test('returns false for empty mimeType', () {
      expect(_makeWith('').isImage, isFalse);
    });

    test('returns false for application/octet-stream', () {
      expect(_makeWith('application/octet-stream').isImage, isFalse);
    });
  });
}
