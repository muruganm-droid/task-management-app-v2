import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project.dart';
import '../../data/models/label.dart';
import '../../domain/repositories/project_repository.dart';
import '../providers.dart';

class ProjectState {
  final List<Project> projects;
  final Project? selectedProject;
  final List<ProjectMember> members;
  final List<Label> labels;
  final bool isLoading;
  final String? error;
  final bool showArchived;

  const ProjectState({
    this.projects = const [],
    this.selectedProject,
    this.members = const [],
    this.labels = const [],
    this.isLoading = false,
    this.error,
    this.showArchived = false,
  });

  List<Project> get activeProjects =>
      projects.where((p) => !p.isArchived).toList();

  List<Project> get archivedProjects =>
      projects.where((p) => p.isArchived).toList();

  ProjectState copyWith({
    List<Project>? projects,
    Project? selectedProject,
    List<ProjectMember>? members,
    List<Label>? labels,
    bool? isLoading,
    String? error,
    bool? showArchived,
    bool clearError = false,
    bool clearSelectedProject = false,
  }) {
    return ProjectState(
      projects: projects ?? this.projects,
      selectedProject: clearSelectedProject
          ? null
          : (selectedProject ?? this.selectedProject),
      members: members ?? this.members,
      labels: labels ?? this.labels,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      showArchived: showArchived ?? this.showArchived,
    );
  }
}

class ProjectViewModel extends Notifier<ProjectState> {
  late final ProjectRepository _repository;

  @override
  ProjectState build() {
    _repository = ref.watch(projectRepositoryProvider);
    return const ProjectState();
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final projects = await _repository.listProjects();
      state = state.copyWith(projects: projects, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectProject(Project project) {
    state = state.copyWith(selectedProject: project);
  }

  Future<Project> createProject(String name, String? description) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final project = await _repository.createProject(
        name: name,
        description: description,
      );
      state = state.copyWith(
        projects: [project, ...state.projects],
        isLoading: false,
      );
      return project;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _repository.deleteProject(projectId);
      state = state.copyWith(
        projects: state.projects.where((p) => p.id != projectId).toList(),
        clearSelectedProject: state.selectedProject?.id == projectId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadMembers(String projectId) async {
    try {
      final members = await _repository.listMembers(projectId);
      state = state.copyWith(members: members);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMember(
    String projectId, {
    required String email,
    required String role,
  }) async {
    try {
      final member = await _repository.addMember(
        projectId,
        email: email,
        role: role,
      );
      state = state.copyWith(members: [...state.members, member]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeMember(String projectId, String userId) async {
    try {
      await _repository.removeMember(projectId, userId);
      state = state.copyWith(
        members: state.members.where((m) => m.userId != userId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadLabels(String projectId) async {
    try {
      final labels = await _repository.listLabels(projectId);
      state = state.copyWith(labels: labels);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createLabel(
    String projectId, {
    required String name,
    required String color,
  }) async {
    try {
      final label = await _repository.createLabel(
        projectId,
        name: name,
        color: color,
      );
      state = state.copyWith(labels: [...state.labels, label]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void toggleShowArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }
}

final projectViewModelProvider =
    NotifierProvider<ProjectViewModel, ProjectState>(ProjectViewModel.new);
