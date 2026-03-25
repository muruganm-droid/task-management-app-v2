import '../models/project.dart';
import '../models/label.dart';
import '../services/project_service.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectService _projectService;

  ProjectRepositoryImpl(this._projectService);

  @override
  Future<List<Project>> listProjects() => _projectService.listProjects();

  @override
  Future<Project> createProject({required String name, String? description}) =>
      _projectService.createProject(name: name, description: description);

  @override
  Future<Project> getProject(String projectId) =>
      _projectService.getProject(projectId);

  @override
  Future<Project> updateProject(
    String projectId, {
    String? name,
    String? description,
  }) => _projectService.updateProject(
    projectId,
    name: name,
    description: description,
  );

  @override
  Future<void> deleteProject(String projectId) =>
      _projectService.deleteProject(projectId);

  @override
  Future<List<ProjectMember>> listMembers(String projectId) =>
      _projectService.listMembers(projectId);

  @override
  Future<ProjectMember> addMember(
    String projectId, {
    required String email,
    required String role,
  }) => _projectService.addMember(projectId, email: email, role: role);

  @override
  Future<ProjectMember> updateMemberRole(
    String projectId,
    String userId, {
    required String role,
  }) => _projectService.updateMemberRole(projectId, userId, role: role);

  @override
  Future<void> removeMember(String projectId, String userId) =>
      _projectService.removeMember(projectId, userId);

  @override
  Future<List<Label>> listLabels(String projectId) =>
      _projectService.listLabels(projectId);

  @override
  Future<Label> createLabel(
    String projectId, {
    required String name,
    required String color,
  }) => _projectService.createLabel(projectId, name: name, color: color);
}
