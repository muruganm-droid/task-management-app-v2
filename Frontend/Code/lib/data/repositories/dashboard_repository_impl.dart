import '../models/dashboard.dart';
import '../models/task.dart';
import '../services/dashboard_service.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardService _dashboardService;

  DashboardRepositoryImpl(this._dashboardService);

  @override
  Future<List<Task>> getMyTasks() => _dashboardService.getMyTasks();

  @override
  Future<ProjectDashboard> getProjectDashboard(String projectId) =>
      _dashboardService.getProjectDashboard(projectId);

  @override
  Future<DashboardTrends> getTrends() => _dashboardService.getTrends();
}
