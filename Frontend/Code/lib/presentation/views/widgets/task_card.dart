import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/haptic_helper.dart';
import '../../../data/models/task.dart';
import '../theme.dart';
import 'priority_badge.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final priorityColor = AppTheme.priorityColor(widget.task.priority.value);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          Haptic.light();
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? priorityColor.withValues(alpha: 0.4)
                  : isDark
                      ? AppTheme.darkBorder
                      : AppTheme.borderColor,
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: _isPressed
                ? AppTheme.glowShadow(priorityColor)
                : isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimaryColor,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PriorityBadge(priority: widget.task.priority, compact: true),
                ],
              ),
              if (widget.task.description != null &&
                  widget.task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    widget.task.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondaryColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Row(
                  children: [
                    if (widget.task.dueDate != null) ...[
                      _buildChip(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('MMM d').format(widget.task.dueDate!),
                        color: widget.task.isOverdue
                            ? AppTheme.errorColor
                            : context.textSecondaryColor,
                        isHighlighted: widget.task.isOverdue,
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.task.subTasks.isNotEmpty) ...[
                      _buildChip(
                        icon: Icons.check_circle_outline,
                        label:
                            '${widget.task.completedSubTaskCount}/${widget.task.subTasks.length}',
                        color: widget.task.completedSubTaskCount ==
                                widget.task.subTasks.length
                            ? AppTheme.successColor
                            : context.textSecondaryColor,
                        isHighlighted: false,
                      ),
                    ],
                    const Spacer(),
                    if (widget.task.assigneeIds.isNotEmpty)
                      _buildAssigneeAvatars(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeAvatars() {
    final count = widget.task.assigneeIds.length;
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
    ];
    return SizedBox(
      width: count > 1 ? 36 : 22,
      height: 22,
      child: Stack(
        children: List.generate(
          count > 3 ? 3 : count,
          (index) => Positioned(
            left: index * 14.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors[index % colors.length],
                    colors[index % colors.length].withValues(alpha: 0.7),
                  ],
                ),
                border: Border.all(
                  color: context.cardSurface,
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.transparent,
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
