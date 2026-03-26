import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/project.dart';
import '../../../data/models/task.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../providers.dart';
import '../theme.dart';
import '../widgets/task_card.dart';
import '../widgets/shimmer_list.dart';
import '../animations/animated_list_item.dart';
import '../tasks/task_detail_screen.dart';
import '../tasks/create_task_screen.dart';
import '../tasks/voice_task_screen.dart' show showVoiceTaskSheet;

class ProjectBoardScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectBoardScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectBoardScreen> createState() =>
      _ProjectBoardScreenState();
}

class _ProjectBoardScreenState extends ConsumerState<ProjectBoardScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  // Track which column is currently being hovered while dragging
  TaskStatus? _hoveredColumn;
  // Track the task currently being dragged (for ghost placeholder)
  Task? _draggingTask;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskViewModelProvider);
    final isDark = context.isDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isDark),
              if (taskState.statusFilter != null ||
                  taskState.priorityFilter != null ||
                  taskState.searchQuery.isNotEmpty)
                _buildActiveFilters(taskState, isDark),
              Expanded(
                child: taskState.isLoading
                    ? const ShimmerTaskList(itemCount: 4)
                    : _buildKanbanBoard(taskState, isDark),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleOnTap(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CreateTaskScreen(projectId: widget.project.id),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: context.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: context.textSecondaryColor.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      filled: false,
                    ),
                    onChanged: (value) {
                      ref
                          .read(taskViewModelProvider.notifier)
                          .setSearchQuery(value);
                    },
                  )
                : Text(
                    widget.project.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isSearching ? Icons.close_rounded : Icons.search_rounded,
                size: 18,
                color: context.textPrimaryColor,
              ),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref
                      .read(taskViewModelProvider.notifier)
                      .setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: context.textPrimaryColor,
              ),
            ),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 18,
                color: context.textPrimaryColor,
              ),
            ),
            onPressed: () async {
              final result = await showVoiceTaskSheet(
                context,
                projectId: widget.project.id,
              );
              if (result == true && mounted) {
                ref
                    .read(taskViewModelProvider.notifier)
                    .loadTasks(widget.project.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(TaskState taskState, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          if (taskState.statusFilter != null)
            _buildFilterTag(
              taskState.statusFilter!.displayName,
              () => ref
                  .read(taskViewModelProvider.notifier)
                  .setStatusFilter(null),
              isDark,
            ),
          if (taskState.priorityFilter != null)
            _buildFilterTag(
              taskState.priorityFilter!.displayName,
              () => ref
                  .read(taskViewModelProvider.notifier)
                  .setPriorityFilter(null),
              isDark,
            ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                ref.read(taskViewModelProvider.notifier).clearFilters(),
            child: Text(
              'Clear all',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(
    String label,
    VoidCallback onRemove,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Kanban Board ────────────────────────────────────────────────────────────

  Widget _buildKanbanBoard(TaskState taskState, bool isDark) {
    final boardStatuses = [
      TaskStatus.todo,
      TaskStatus.inProgress,
      TaskStatus.underReview,
      TaskStatus.done,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: boardStatuses.asMap().entries.map((entry) {
          final index = entry.key;
          final status = entry.value;
          final tasks = taskState.getTasksByStatus(status);
          final color = AppTheme.statusColor(status.value);
          final isHovered = _hoveredColumn == status;

          return FadeInWidget(
            delay: Duration(milliseconds: index * 80),
            child: _buildColumn(
              status: status,
              tasks: tasks,
              color: color,
              isDark: isDark,
              isHovered: isHovered,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumn({
    required TaskStatus status,
    required List<Task> tasks,
    required Color color,
    required bool isDark,
    required bool isHovered,
  }) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        // Accept any task dropped onto a different column
        if (details.data.status != status) {
          setState(() => _hoveredColumn = status);
          return true;
        }
        return false;
      },
      onLeave: (_) {
        setState(() => _hoveredColumn = null);
      },
      onAcceptWithDetails: (details) {
        setState(() => _hoveredColumn = null);
        _handleDrop(details.data, status);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: isHovered
                ? Border.all(color: color.withValues(alpha: 0.6), width: 2)
                : null,
            boxShadow: isHovered
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Column header
              _buildColumnHeader(
                status: status,
                tasks: tasks,
                color: color,
                isDark: isDark,
                isHovered: isHovered,
              ),
              // Column body
              _buildColumnBody(
                status: status,
                tasks: tasks,
                color: color,
                isDark: isDark,
                isHovered: isHovered,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColumnHeader({
    required TaskStatus status,
    required List<Task> tasks,
    required Color color,
    required bool isDark,
    required bool isHovered,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isHovered
            ? color.withValues(alpha: isDark ? 0.18 : 0.12)
            : color.withValues(alpha: isDark ? 0.1 : 0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: isHovered
              ? color.withValues(alpha: 0.4)
              : color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${tasks.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          // Drag hint icon in header
          Icon(
            Icons.drag_indicator,
            size: 16,
            color: color.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnBody({
    required TaskStatus status,
    required List<Task> tasks,
    required Color color,
    required bool isDark,
    required bool isHovered,
  }) {
    // Constrain height to fit within the screen (approx)
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 220,
        minHeight: 120,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovered
              ? (isDark
                  ? color.withValues(alpha: 0.06)
                  : color.withValues(alpha: 0.03))
              : (isDark
                  ? AppTheme.darkCard.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.6)),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          border: Border.all(
            color: isHovered
                ? color.withValues(alpha: 0.3)
                : isDark
                    ? AppTheme.darkBorder
                    : AppTheme.borderColor,
          ),
        ),
        child: tasks.isEmpty
            ? _buildEmptyColumn(color, isDark, isHovered)
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  final isBeingDragged = _draggingTask?.id == task.id;

                  return AnimatedListItem(
                    index: i,
                    child: isBeingDragged
                        ? _buildGhostPlaceholder()
                        : _buildDraggableTaskCard(task),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyColumn(Color color, bool isDark, bool isHovered) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: isHovered
                    ? color.withValues(alpha: 0.5)
                    : context.textSecondaryColor.withValues(alpha: 0.15),
                width: isHovered ? 2 : 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isHovered ? Icons.add_circle_outline : Icons.inbox_outlined,
              size: 24,
              color: isHovered
                  ? color.withValues(alpha: 0.7)
                  : context.textSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isHovered ? 'Drop here' : 'No tasks',
            style: TextStyle(
              color: isHovered
                  ? color.withValues(alpha: 0.8)
                  : context.textSecondaryColor.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(Task task) {
    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 300),
      onDragStarted: () {
        setState(() => _draggingTask = task);
      },
      onDragEnd: (_) {
        setState(() => _draggingTask = null);
      },
      onDraggableCanceled: (_, _) {
        setState(() => _draggingTask = null);
      },
      // The widget shown while dragging (semi-transparent feedback)
      feedback: _buildDragFeedback(task),
      // The widget shown at the original position while dragging
      childWhenDragging: _buildGhostPlaceholder(),
      child: Stack(
        children: [
          TaskCard(
            task: task,
            onTap: () => _openTaskDetail(task),
          ),
          // Drag handle overlay (top-right)
          Positioned(
            top: 10,
            right: 10,
            child: Icon(
              Icons.drag_indicator,
              size: 16,
              color: context.textSecondaryColor.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragFeedback(Task task) {
    final isDark = context.isDark;
    final priorityColor = AppTheme.priorityColor(task.priority.value);

    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.85,
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: priorityColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: priorityColor.withValues(alpha: 0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      priorityColor,
                      priorityColor.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.drag_indicator,
                size: 18,
                color: priorityColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGhostPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.35),
          width: 2,
          // Dashed border effect via a custom painter is complex;
          // We use a lighter solid border with reduced opacity instead
        ),
        color: AppTheme.primaryColor.withValues(alpha: 0.04),
      ),
      child: Center(
        child: Icon(
          Icons.drag_indicator,
          size: 20,
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  // ─── Drop Handler ────────────────────────────────────────────────────────────

  Future<void> _handleDrop(Task task, TaskStatus newStatus) async {
    if (task.status == newStatus) return;

    final taskNotifier = ref.read(taskViewModelProvider.notifier);
    final taskService = ref.read(taskServiceProvider);
    final currentTasks = ref.read(taskViewModelProvider).tasks;

    // Calculate new position (append to end of column)
    final tasksInNewColumn = currentTasks
        .where((t) => t.status == newStatus && t.id != task.id)
        .toList();
    final newPosition = tasksInNewColumn.length;

    // Optimistic update: move the card locally immediately
    final optimisticTask = task.copyWith(status: newStatus, position: newPosition);
    final updatedTasks = currentTasks.map((t) {
      return t.id == task.id ? optimisticTask : t;
    }).toList();
    taskNotifier.setTasks(updatedTasks);

    // Persist via API
    try {
      final serverTask = await taskService.reorderTask(
        task.id,
        newStatus.value,
        newPosition,
      );
      // Apply the server's authoritative response
      final serverTasks = ref.read(taskViewModelProvider).tasks.map((t) {
        return t.id == task.id ? serverTask : t;
      }).toList();
      taskNotifier.setTasks(serverTasks);
    } catch (_) {
      // Rollback: restore original task list on failure
      taskNotifier.setTasks(currentTasks);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to move task. Please try again.'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _openTaskDetail(Task task) {
    ref.read(taskViewModelProvider.notifier).selectTask(task);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TaskDetailScreen(task: task),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  // ─── Filter Sheet ─────────────────────────────────────────────────────────────

  void _showFilterSheet(BuildContext context) {
    final taskState = ref.read(taskViewModelProvider);
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.textSecondaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter Tasks',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in TaskStatus.values.where(
                    (s) => s != TaskStatus.archived,
                  ))
                    ChoiceChip(
                      label: Text(status.displayName),
                      selected: taskState.statusFilter == status,
                      onSelected: (selected) {
                        ref
                            .read(taskViewModelProvider.notifier)
                            .setStatusFilter(selected ? status : null);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Priority',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final priority in TaskPriority.values)
                    ChoiceChip(
                      label: Text(priority.displayName),
                      selected: taskState.priorityFilter == priority,
                      onSelected: (selected) {
                        ref
                            .read(taskViewModelProvider.notifier)
                            .setPriorityFilter(
                                selected ? priority : null);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(taskViewModelProvider.notifier)
                        .clearFilters();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Clear All Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
