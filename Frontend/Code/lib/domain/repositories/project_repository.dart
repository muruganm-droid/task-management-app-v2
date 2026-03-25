import '../../data/models/project.dart';
import '../../data/models/label.dart';

abstract class ProjectRepository {
  Future<List<Project>> listProjects();
  Future<Project> createProject({required String name, String? description});
  Future<Project> getProject(String projectId);
  Future<Project> updateProject(
    String projectId, {
    String? name,
    String? description,
  });
  Future<void> deleteProject(String projectId);

  // Members
  Future<List<ProjectMember>> listMembers(String projectId);
  Future<ProjectMember> addMember(
    String projectId, {
    required String email,
    required String role,
  });
  Future<ProjectMember> updateMemberRole(
    String projectId,
    String userId, {
    required String role,
  });
  Future<void> removeMember(String projectId, String userId);

  // Labels
  Future<List<Label>> listLabels(String projectId);
  Future<Label> createLabel(
    String projectId, {
    required String name,
    required String color,
  });
}
