import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task.dart';
import '../../../data/models/comment.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/comment_viewmodel.dart';
import '../../../presentation/providers.dart';
import '../theme.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';
import '../widgets/empty_state.dart';
import '../animations/animated_list_item.dart';
import '../widgets/attachment_picker.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Task _task;
  final _commentController = TextEditingController();
  late AnimationController _headerAnim;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  List<Map<String, dynamic>> _attachments = [];
  bool _attachmentsLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _task = widget.task;

    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _headerAnim,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerAnim,
        curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _headerAnim.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentViewModelProvider.notifier).loadComments(_task.id);
      _loadAttachments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentViewModelProvider);
    final isDark = context.isDark;
    final priorityColor = AppTheme.priorityColor(_task.priority.value);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildCustomAppBar(isDark, priorityColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  AnimatedBuilder(
                    animation: _headerAnim,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _headerOpacity.value,
                        child: SlideTransition(
                          position: _headerSlide,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _task.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                            letterSpacing: -0.5,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildBadgeRow(isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatusSelector(isDark),
                  const SizedBox(height: 20),
                  if (_task.description != null &&
                      _task.description!.isNotEmpty)
                    _buildDescriptionCard(isDark),
                  if (_task.subTasks.isNotEmpty) _buildChecklistCard(isDark),
                  const SizedBox(height: 8),
                  _buildTabSection(commentState, isDark),
                ],
              ),
            ),
            _buildCommentInput(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(bool isDark, Color priorityColor) {
    return SafeArea(
      bottom: false,
      child: Padding(
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Task Detail',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') _confirmDelete();
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: context.textPrimaryColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.errorColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Delete Task',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(bool isDark) {
    return Row(
      children: [
        StatusBadge(status: _task.status),
        const SizedBox(width: 8),
        PriorityBadge(priority: _task.priority),
        const Spacer(),
        if (_task.dueDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _task.isOverdue
                  ? AppTheme.errorColor.withValues(alpha: isDark ? 0.15 : 0.08)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: _task.isOverdue
                  ? Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                    )
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: _task.isOverdue
                      ? AppTheme.errorColor
                      : context.textSecondaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  DateFormat('MMM d, yyyy').format(_task.dueDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: _task.isOverdue
                        ? AppTheme.errorColor
                        : context.textSecondaryColor,
                    fontWeight: _task.isOverdue
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSelector(bool isDark) {
    return AnimatedListItem(
      index: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Status',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskStatus.values
                  .where((s) => s != TaskStatus.archived)
                  .map((status) {
                final isSelected = _task.status == status;
                final color = AppTheme.statusColor(status.value);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _task = _task.copyWith(status: status);
                      });
                      ref
                          .read(taskViewModelProvider.notifier)
                          .updateTaskStatus(_task.id, status);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.15)
                            : isDark
                                ? AppTheme.darkCard
                                : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.4)
                              : isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            color.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status.displayName,
                            style: TextStyle(
                              color: isSelected
                                  ? color
                                  : context.textSecondaryColor,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDescriptionCard(bool isDark) {
    return AnimatedListItem(
      index: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              _task.description!,
              style: TextStyle(
                fontSize: 14,
                color: context.textPrimaryColor,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(bool isDark) {
    final progress = _task.subTasks.isEmpty
        ? 0.0
        : _task.completedSubTaskCount / _task.subTasks.length;

    return AnimatedListItem(
      index: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Checklist',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor
                      .withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_task.completedSubTaskCount}/${_task.subTasks.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor:
                      isDark ? AppTheme.darkBorder : AppTheme.borderColor,
                  color: AppTheme.successColor,
                  minHeight: 6,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              ),
            ),
            child: Column(
              children: _task.subTasks.asMap().entries.map((entry) {
                final subTask = entry.value;
                final isLast = entry.key == _task.subTasks.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(taskViewModelProvider.notifier)
                            .toggleSubTask(_task.id, subTask.id);
                        setState(() {
                          final updatedSubTasks = _task.subTasks.map((st) {
                            if (st.id == subTask.id) {
                              return st.copyWith(isDone: !st.isDone);
                            }
                            return st;
                          }).toList();
                          _task =
                              _task.copyWith(subTasks: updatedSubTasks);
                        });
                      },
                      borderRadius: BorderRadius.circular(
                        isLast && entry.key == 0 ? 14 : 0,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: subTask.isDone
                                    ? AppTheme.successColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: subTask.isDone
                                    ? null
                                    : Border.all(
                                        color: isDark
                                            ? AppTheme.darkBorder
                                            : AppTheme.borderColor,
                                        width: 2,
                                      ),
                              ),
                              child: subTask.isDone
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedDefaultTextStyle(
                                duration:
                                    const Duration(milliseconds: 250),
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: subTask.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: subTask.isDone
                                      ? context.textSecondaryColor
                                      : context.textPrimaryColor,
                                  fontWeight: FontWeight.w400,
                                ),
                                child: Text(subTask.title),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 46,
                        color: isDark
                            ? AppTheme.darkBorder
                            : AppTheme.borderColor,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTabSection(CommentState commentState, bool isDark) {
    return AnimatedListItem(
      index: 4,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              ),
            ),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: context.textSecondaryColor,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: const [
                    Tab(text: 'Comments'),
                    Tab(text: 'Activity'),
                    Tab(text: 'Details'),
                    Tab(text: 'Files'),
                  ],
                ),
                SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCommentsTab(commentState.comments, isDark),
                          _buildActivityTab(isDark),
                          _buildDetailsTab(isDark),
                          _buildFilesTab(isDark),
                        ],
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, child) {
                            return _tabController.index == 3
                                ? child!
                                : const SizedBox.shrink();
                          },
                          child: FloatingActionButton.small(
                            heroTag: 'attachment_fab',
                            backgroundColor: AppTheme.primaryColor,
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (_) => const AttachmentPickerSheet(),
                              );
                            },
                            child: const Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAttachments() async {
    if (!mounted) return;
    setState(() => _attachmentsLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get('/tasks/${_task.id}/attachments');
      if (mounted) {
        final data = response.data;
        if (data is List) {
          setState(() {
            _attachments = data
                .whereType<Map<String, dynamic>>()
                .toList();
          });
        } else if (data is Map && data['data'] is List) {
          setState(() {
            _attachments = (data['data'] as List)
                .whereType<Map<String, dynamic>>()
                .toList();
          });
        }
      }
    } catch (_) {
      // Silently handle errors — empty state will be shown
    } finally {
      if (mounted) setState(() => _attachmentsLoading = false);
    }
  }

  Widget _buildFilesTab(bool isDark) {
    if (_attachmentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attachments.isEmpty) {
      return const EmptyState(
        icon: Icons.attach_file_rounded,
        title: 'No attachments',
        subtitle: 'Upload files using the button below',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        final attachment = _attachments[index];
        final filename = attachment['filename'] as String? ?? 'Unknown file';
        final size = attachment['size'];
        final uploader = attachment['uploaderName'] as String? ??
            attachment['uploader'] as String? ??
            'Unknown';
        final uploadedAt = attachment['createdAt'] != null
            ? DateFormat('MMM d, yyyy').format(
                DateTime.tryParse(attachment['createdAt'].toString()) ??
                    DateTime.now(),
              )
            : '';
        final mimeType = attachment['mimeType'] as String? ?? '';
        final url = attachment['url'] as String? ?? '';
        final isImage = mimeType.startsWith('image/');

        String sizeLabel = '';
        if (size != null) {
          final bytes = (size as num).toInt();
          if (bytes < 1024) {
            sizeLabel = '$bytes B';
          } else if (bytes < 1024 * 1024) {
            sizeLabel = '${(bytes / 1024).toStringAsFixed(1)} KB';
          } else {
            sizeLabel = '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isImage && url.isNotEmpty
                      ? Image.network(
                          url,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 44,
                            height: 44,
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppTheme.primaryColor,
                              size: 22,
                            ),
                          ),
                        )
                      : Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filename,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (sizeLabel.isNotEmpty) sizeLabel,
                          uploader,
                          if (uploadedAt.isNotEmpty) uploadedAt,
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsTab(List<Comment> comments, bool isDark) {
    if (comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: context.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 10),
            Text(
              'No comments yet',
              style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start a conversation below',
              style: TextStyle(
                color: context.textSecondaryColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final avatarColors = [
          AppTheme.primaryColor,
          AppTheme.secondaryColor,
          AppTheme.accentColor,
          AppTheme.successColor,
        ];
        final avatarColor =
            avatarColors[comment.authorName.hashCode.abs() % avatarColors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      avatarColor,
                      avatarColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.authorName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(comment.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondaryColor,
                          ),
                        ),
                        if (comment.isEdited)
                          Text(
                            ' (edited)',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8F9FA),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        comment.body,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textPrimaryColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 36,
            color: context.textSecondaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          Text(
            'Activity log',
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Changes will appear here',
            style: TextStyle(
              color: context.textSecondaryColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Created',
              DateFormat('MMM d, yyyy').format(_task.createdAt), isDark),
          _detailRow('Updated',
              DateFormat('MMM d, yyyy').format(_task.updatedAt), isDark),
          _detailRow(
            'Assignees',
            _task.assigneeIds.isEmpty
                ? 'Unassigned'
                : '${_task.assigneeIds.length} member(s)',
            isDark,
          ),
          _detailRow('Project ID', _task.projectId, isDark),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        8,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _commentController,
                style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: TextStyle(
                    color:
                        context.textSecondaryColor.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          ScaleOnTap(
            onTap: () async {
              if (_commentController.text.trim().isEmpty) return;
              try {
                await ref
                    .read(commentViewModelProvider.notifier)
                    .addComment(
                        _task.id, _commentController.text.trim());
                _commentController.clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment added'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add comment'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final isDark = context.isDark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Task',
          style: TextStyle(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
          style: TextStyle(
            color: context.textSecondaryColor,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.textSecondaryColor),
            ),
          ),
          ScaleOnTap(
            onTap: () async {
              Navigator.pop(ctx);
              await ref.read(taskViewModelProvider.notifier).deleteTask(_task.id);
              if (!mounted) return;
              Navigator.pop(context);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.errorGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.isNegative || diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
