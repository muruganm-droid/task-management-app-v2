import '../../data/models/dashboard.dart';
import '../../data/models/task.dart';

abstract class DashboardRepository {
  Future<List<Task>> getMyTasks();
  Future<ProjectDashboard> getProjectDashboard(String projectId);
  Future<DashboardTrends> getTrends();
}
