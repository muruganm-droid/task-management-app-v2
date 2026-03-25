import '../models/comment.dart';
import '../services/comment_service.dart';
import '../../domain/repositories/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentService _commentService;

  CommentRepositoryImpl(this._commentService);

  @override
  Future<List<Comment>> listComments(String taskId) =>
      _commentService.listComments(taskId);

  @override
  Future<Comment> addComment(String taskId, {required String body}) =>
      _commentService.addComment(taskId, body: body);

  @override
  Future<Comment> updateComment(String commentId, {required String body}) =>
      _commentService.updateComment(commentId, body: body);

  @override
  Future<void> deleteComment(String commentId) =>
      _commentService.deleteComment(commentId);
}
