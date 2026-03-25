import 'task.dart';
import 'project.dart';

class SearchResult {
  final List<Task> tasks;
  final List<Project> projects;

  SearchResult({
    required this.tasks,
    required this.projects,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projects:
          (json['projects'] as List<dynamic>?)
              ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
    };
  }
}
