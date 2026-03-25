import '../models/task.dart';
import '../models/activity.dart';
import '../services/task_service.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskService _taskService;

  TaskRepositoryImpl(this._taskService);

  @override
  Future<List<Task>> listProjectTasks(
    String projectId, {
    String? status,
    String? priority,
    String? assigneeId,
    String? labelId,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) => _taskService.listProjectTasks(
    projectId,
    status: status,
    priority: priority,
    assigneeId: assigneeId,
    labelId: labelId,
    search: search,
    sortBy: sortBy,
    sortOrder: sortOrder,
  );

  @override
  Future<Task> createTask(
    String projectId, {
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    List<String>? assigneeIds,
  }) => _taskService.createTask(
    projectId,
    title: title,
    description: description,
    priority: priority,
    dueDate: dueDate,
    assigneeIds: assigneeIds,
  );

  @override
  Future<Task> getTask(String taskId) => _taskService.getTask(taskId);

  @override
  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? status,
    String? priority,
    String? description,
    String? dueDate,
    List<String>? assigneeIds,
  }) => _taskService.updateTask(
    taskId,
    title: title,
    status: status,
    priority: priority,
    description: description,
    dueDate: dueDate,
    assigneeIds: assigneeIds,
  );

  @override
  Future<void> deleteTask(String taskId) => _taskService.deleteTask(taskId);

  @override
  Future<List<SubTask>> listSubtasks(String taskId) =>
      _taskService.listSubtasks(taskId);

  @override
  Future<SubTask> createSubtask(String taskId, {required String title}) =>
      _taskService.createSubtask(taskId, title: title);

  @override
  Future<SubTask> updateSubtask(
    String taskId,
    String subtaskId, {
    String? title,
    bool? isDone,
  }) => _taskService.updateSubtask(
    taskId,
    subtaskId,
    title: title,
    isDone: isDone,
  );

  @override
  Future<void> deleteSubtask(String taskId, String subtaskId) =>
      _taskService.deleteSubtask(taskId, subtaskId);

  @override
  Future<void> attachLabels(String taskId, List<String> labelIds) =>
      _taskService.attachLabels(taskId, labelIds);

  @override
  Future<void> removeLabel(String taskId, String labelId) =>
      _taskService.removeLabel(taskId, labelId);

  @override
  Future<List<Activity>> getActivity(String taskId) =>
      _taskService.getActivity(taskId);
}
