import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/analytics.dart';
import '../../../data/services/dashboard_service.dart';
import '../../providers.dart';
import '../theme.dart';
import '../animations/animated_list_item.dart';

// ─── Analytics state & notifier ───────────────────────────────────────────────

class AnalyticsState {
  final bool isLoading;
  final Analytics? data;
  final String? error;

  const AnalyticsState({this.isLoading = false, this.data, this.error});

  AnalyticsState copyWith({bool? isLoading, Analytics? data, String? error}) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final DashboardService _service;

  AnalyticsNotifier(this._service) : super(const AnalyticsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.getAnalytics();
      state = state.copyWith(isLoading: false, data: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final analyticsProvider =
    StateNotifierProvider.autoDispose<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(dashboardServiceProvider));
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              Expanded(
                child: state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : state.error != null
                        ? _buildError(state.error!)
                        : state.data != null
                            ? _buildContent(state.data!, isDark)
                            : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: context.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Analytics',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
              letterSpacing: -0.4,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => ref.read(analyticsProvider.notifier).load(),
            icon: Icon(
              Icons.refresh_rounded,
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppTheme.errorColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load analytics',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => ref.read(analyticsProvider.notifier).load(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Analytics data, bool isDark) {
    return RefreshIndicator(
      onRefresh: () => ref.read(analyticsProvider.notifier).load(),
      color: AppTheme.primaryColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          AnimatedListItem(
            index: 0,
            child: _buildKpiGrid(data, isDark),
          ),
          const SizedBox(height: 20),
          AnimatedListItem(
            index: 1,
            child: _buildStatusDistribution(data, isDark),
          ),
          const SizedBox(height: 20),
          AnimatedListItem(
            index: 2,
            child: _buildWeeklyTrend(data, isDark),
          ),
          const SizedBox(height: 20),
          AnimatedListItem(
            index: 3,
            child: _buildTeamWorkload(data, isDark),
          ),
        ],
      ),
    );
  }

  // ─── KPI 2x2 grid ──────────────────────────────────────────────────────────

  Widget _buildKpiGrid(Analytics data, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Overview', isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: 'Completion Rate',
                value: '${data.completionRate}%',
                icon: Icons.pie_chart_rounded,
                color: AppTheme.successColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: 'Overdue',
                value: '${data.overdueTasks}',
                icon: Icons.warning_amber_rounded,
                color: AppTheme.errorColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                label: 'Avg. Days',
                value: data.avgCompletionDays.toStringAsFixed(1),
                icon: Icons.timelapse_rounded,
                color: AppTheme.accentColor,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                label: 'Total Tasks',
                value: '${data.totalTasks}',
                icon: Icons.task_alt_rounded,
                color: AppTheme.primaryColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Status distribution ────────────────────────────────────────────────────

  Widget _buildStatusDistribution(Analytics data, bool isDark) {
    if (data.tasksByStatus.isEmpty) return const SizedBox.shrink();

    final total =
        data.tasksByStatus.fold<int>(0, (sum, e) => sum + e.count);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Status Distribution', isDark),
          const SizedBox(height: 16),
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: data.tasksByStatus.map((s) {
                final fraction = total > 0 ? s.count / total : 0.0;
                final color = AppTheme.statusColor(s.status);
                return Flexible(
                  flex: (fraction * 1000).round(),
                  child: Container(height: 10, color: color),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.tasksByStatus.map((s) {
              final color = AppTheme.statusColor(s.status);
              final pct = total > 0
                  ? ((s.count / total) * 100).toStringAsFixed(0)
                  : '0';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_statusLabel(s.status)} $pct%',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TODO':
        return 'To Do';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'UNDER_REVIEW':
        return 'Review';
      case 'DONE':
        return 'Done';
      case 'ARCHIVED':
        return 'Archived';
      default:
        return status;
    }
  }

  // ─── Weekly trend bar chart ─────────────────────────────────────────────────

  Widget _buildWeeklyTrend(Analytics data, bool isDark) {
    if (data.weeklyStats.isEmpty) return const SizedBox.shrink();

    final maxValue = data.weeklyStats
        .fold<int>(
            0, (m, s) => [m, s.created, s.completed].reduce((a, b) => a > b ? a : b))
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Weekly Trend', isDark),
          const SizedBox(height: 4),
          Row(
            children: [
              _legendDot(AppTheme.primaryColor, 'Created'),
              const SizedBox(width: 16),
              _legendDot(AppTheme.successColor, 'Completed'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.weeklyStats.map((w) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bars stacked side-by-side
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bar(
                              value: w.created.toDouble(),
                              max: maxValue,
                              color: AppTheme.primaryColor,
                              maxHeight: 90,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 2),
                            _bar(
                              value: w.completed.toDouble(),
                              max: maxValue,
                              color: AppTheme.successColor,
                              maxHeight: 90,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _weekLabel(w.weekStart),
                          style: TextStyle(
                            fontSize: 9,
                            color: context.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({
    required double value,
    required double max,
    required Color color,
    required double maxHeight,
    required bool isDark,
  }) {
    final h = max > 0 ? (value / max) * maxHeight : 4.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      width: 12,
      height: h.clamp(4.0, maxHeight),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: context.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _weekLabel(String weekStart) {
    if (weekStart.isEmpty) return '';
    try {
      final dt = DateTime.parse(weekStart);
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return weekStart.length > 5 ? weekStart.substring(5, 10) : weekStart;
    }
  }

  // ─── Team workload ──────────────────────────────────────────────────────────

  Widget _buildTeamWorkload(Analytics data, bool isDark) {
    if (data.teamWorkload.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Team Workload', isDark),
          const SizedBox(height: 14),
          ...data.teamWorkload.asMap().entries.map(
                (entry) => _buildWorkloadRow(entry.value, isDark),
              ),
        ],
      ),
    );
  }

  Widget _buildWorkloadRow(TeamWorkload member, bool isDark) {
    final progress = member.total > 0 ? member.done / member.total : 0.0;
    final progressColor = progress >= 0.8
        ? AppTheme.successColor
        : progress >= 0.5
            ? AppTheme.warningColor
            : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${member.done}/${member.total}',
                      style: TextStyle(
                        fontSize: 12,
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppTheme.darkCardAlt
                        : AppTheme.surfaceColor,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared helpers ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.4),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.textPrimaryColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppTheme.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
