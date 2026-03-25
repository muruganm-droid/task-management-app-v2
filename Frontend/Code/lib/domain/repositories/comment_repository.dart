import '../../data/models/comment.dart';

abstract class CommentRepository {
  Future<List<Comment>> listComments(String taskId);
  Future<Comment> addComment(String taskId, {required String body});
  Future<Comment> updateComment(String commentId, {required String body});
  Future<void> deleteComment(String commentId);
}
