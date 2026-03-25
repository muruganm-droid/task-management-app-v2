import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../providers.dart';

class CommentState {
  final List<Comment> comments;
  final bool isLoading;
  final String? error;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CommentViewModel extends Notifier<CommentState> {
  late final CommentRepository _repository;

  @override
  CommentState build() {
    _repository = ref.watch(commentRepositoryProvider);
    return const CommentState();
  }

  Future<void> loadComments(String taskId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final comments = await _repository.listComments(taskId);
      state = state.copyWith(comments: comments, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addComment(String taskId, String body) async {
    try {
      final comment = await _repository.addComment(taskId, body: body);
      state = state.copyWith(comments: [...state.comments, comment]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updateComment(String commentId, String body) async {
    try {
      final updated = await _repository.updateComment(commentId, body: body);
      final updatedList = state.comments.map((c) {
        return c.id == commentId ? updated : c;
      }).toList();
      state = state.copyWith(comments: updatedList);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final commentViewModelProvider =
    NotifierProvider<CommentViewModel, CommentState>(CommentViewModel.new);
