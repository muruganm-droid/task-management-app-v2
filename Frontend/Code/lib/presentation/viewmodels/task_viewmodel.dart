import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../providers.dart';

class TaskState {
  final List<Task> tasks;
  final Task? selectedTask;
  final bool isLoading;
  final String? error;
  final TaskStatus? statusFilter;
  final TaskPriority? priorityFilter;
  final String searchQuery;

  const TaskState({
    this.tasks = const [],
    this.selectedTask,
    this.isLoading = false,
    this.error,
    this.statusFilter,
    this.priorityFilter,
    this.searchQuery = '',
  });

  List<Task> get filteredTasks {
    var filtered = List<Task>.from(tasks);
    if (statusFilter != null) {
      filtered = filtered.where((t) => t.status == statusFilter).toList();
    }
    if (priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == priorityFilter).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(query) ||
            (t.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    return filtered;
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return filteredTasks.where((t) => t.status == status).toList();
  }

  List<Task> get overdueTasks => tasks.where((t) => t.isOverdue).toList();

  List<Task> get myTasks => tasks;

  Map<TaskStatus, int> get taskCountByStatus {
    final map = <TaskStatus, int>{};
    for (final status in TaskStatus.values) {
      map[status] = tasks.where((t) => t.status == status).length;
    }
    return map;
  }

  TaskState copyWith({
    List<Task>? tasks,
    Task? selectedTask,
    bool? isLoading,
    String? error,
    TaskStatus? statusFilter,
    TaskPriority? priorityFilter,
    String? searchQuery,
    bool clearError = false,
    bool clearStatusFilter = false,
    bool clearPriorityFilter = false,
    bool clearSelectedTask = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedTask: clearSelectedTask
          ? null
          : (selectedTask ?? this.selectedTask),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      priorityFilter: clearPriorityFilter
          ? null
          : (priorityFilter ?? this.priorityFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TaskViewModel extends Notifier<TaskState> {
  late final TaskRepository _repository;

  @override
  TaskState build() {
    _repository = ref.watch(taskRepositoryProvider);
    return const TaskState();
  }

  Future<void> loadTasks(String projectId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _repository.listProjectTasks(projectId);
      state = state.copyWith(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sets tasks directly, used by dashboard viewmodel to populate
  /// user tasks fetched from the dashboard API.
  void setTasks(List<Task> tasks) {
    state = state.copyWith(tasks: tasks, isLoading: false);
  }

  void selectTask(Task task) {
    state = state.copyWith(selectedTask: task);
  }

  Future<Task> createTask({
    required String projectId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> assigneeIds = const [],
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final task = await _repository.createTask(
        projectId,
        title: title,
        description: description,
        priority: priority.value,
        dueDate: dueDate?.toIso8601String(),
        assigneeIds: assigneeIds,
      );
      state = state.copyWith(tasks: [task, ...state.tasks], isLoading: false);
      return task;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final updatedTask = await _repository.updateTask(
        taskId,
        status: newStatus.value,
      );
      final updatedTasks = state.tasks.map((t) {
        return t.id == taskId ? updatedTask : t;
      }).toList();
      state = state.copyWith(
        tasks: updatedTasks,
        selectedTask: state.selectedTask?.id == taskId
            ? updatedTask
            : state.selectedTask,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = await _repository.updateTask(
        task.id,
        title: task.title,
        description: task.description,
        status: task.status.value,
        priority: task.priority.value,
        dueDate: task.dueDate?.toIso8601String(),
      );
      final updatedTasks = state.tasks.map((t) {
        return t.id == task.id ? updatedTask : t;
      }).toList();
      state = state.copyWith(
        tasks: updatedTasks,
        selectedTask: state.selectedTask?.id == task.id
            ? updatedTask
            : state.selectedTask,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != taskId).toList(),
        clearSelectedTask: state.selectedTask?.id == taskId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleSubTask(String taskId, String subTaskId) async {
    final taskIndex = state.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = state.tasks[taskIndex];
    final subTaskIndex = task.subTasks.indexWhere((s) => s.id == subTaskId);
    if (subTaskIndex == -1) return;
    final subTask = task.subTasks[subTaskIndex];

    try {
      await _repository.updateSubtask(
        taskId,
        subTaskId,
        isDone: !subTask.isDone,
      );
      final updatedSubTasks = task.subTasks.map((st) {
        if (st.id == subTaskId) return st.copyWith(isDone: !st.isDone);
        return st;
      }).toList();
      final updatedTask = task.copyWith(subTasks: updatedSubTasks);
      final updatedTasks = List<Task>.from(state.tasks);
      updatedTasks[taskIndex] = updatedTask;
      state = state.copyWith(
        tasks: updatedTasks,
        selectedTask: state.selectedTask?.id == taskId
            ? updatedTask
            : state.selectedTask,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setStatusFilter(TaskStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }

  void setPriorityFilter(TaskPriority? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriorityFilter: true);
    } else {
      state = state.copyWith(priorityFilter: priority);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = state.copyWith(
      clearStatusFilter: true,
      clearPriorityFilter: true,
      searchQuery: '',
    );
  }
}

final taskViewModelProvider = NotifierProvider<TaskViewModel, TaskState>(
  TaskViewModel.new,
);
