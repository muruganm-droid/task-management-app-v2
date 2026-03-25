import '../../data/models/task.dart';
import '../../data/models/activity.dart';

abstract class TaskRepository {
  Future<List<Task>> listProjectTasks(
    String projectId, {
    String? status,
    String? priority,
    String? assigneeId,
    String? labelId,
    String? search,
    String? sortBy,
    String? sortOrder,
  });
  Future<Task> createTask(
    String projectId, {
    required String title,
    String? description,
    String? priority,
    String? dueDate,
    List<String>? assigneeIds,
  });
  Future<Task> getTask(String taskId);
  Future<Task> updateTask(
    String taskId, {
    String? title,
    String? status,
    String? priority,
    String? description,
    String? dueDate,
    List<String>? assigneeIds,
  });
  Future<void> deleteTask(String taskId);

  // Subtasks
  Future<List<SubTask>> listSubtasks(String taskId);
  Future<SubTask> createSubtask(String taskId, {required String title});
  Future<SubTask> updateSubtask(
    String taskId,
    String subtaskId, {
    String? title,
    bool? isDone,
  });
  Future<void> deleteSubtask(String taskId, String subtaskId);

  // Labels on tasks
  Future<void> attachLabels(String taskId, List<String> labelIds);
  Future<void> removeLabel(String taskId, String labelId);

  // Activity
  Future<List<Activity>> getActivity(String taskId);
}
