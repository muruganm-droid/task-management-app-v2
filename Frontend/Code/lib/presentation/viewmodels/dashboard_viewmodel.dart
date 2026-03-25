import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task.dart';
import '../../data/models/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../providers.dart';

class DashboardState {
  final List<Task> myTasks;
  final DashboardTrends? trends;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.myTasks = const [],
    this.trends,
    this.isLoading = false,
    this.error,
  });

  List<Task> get overdueTasks => myTasks.where((t) => t.isOverdue).toList();

  Map<TaskStatus, int> get taskCountByStatus {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = myTasks.where((t) => t.status == status).length;
    }
    return map;
  }

  DashboardState copyWith({
    List<Task>? myTasks,
    DashboardTrends? trends,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      myTasks: myTasks ?? this.myTasks,
      trends: trends ?? this.trends,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DashboardViewModel extends Notifier<DashboardState> {
  late final DashboardRepository _repository;

  @override
  DashboardState build() {
    _repository = ref.watch(dashboardRepositoryProvider);
    return const DashboardState();
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _repository.getMyTasks();
      state = state.copyWith(myTasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTrends() async {
    try {
      final trends = await _repository.getTrends();
      state = state.copyWith(trends: trends);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(
      DashboardViewModel.new,
    );
