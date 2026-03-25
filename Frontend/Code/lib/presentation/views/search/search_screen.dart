import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task.dart';
import '../../../data/models/project.dart';
import '../../../data/models/search_result.dart';
import '../../../data/services/search_service.dart';
import '../../providers.dart';
import '../theme.dart';
import '../animations/animated_list_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_badge.dart';

// ─── Search state ─────────────────────────────────────────────────────────────

class SearchScreenState {
  final bool isLoading;
  final SearchResult? results;
  final String? error;
  final String query;

  const SearchScreenState({
    this.isLoading = false,
    this.results,
    this.error,
    this.query = '',
  });

  SearchScreenState copyWith({
    bool? isLoading,
    SearchResult? results,
    String? error,
    String? query,
  }) {
    return SearchScreenState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error ?? this.error,
      query: query ?? this.query,
    );
  }

  bool get hasResults =>
      results != null &&
      (results!.tasks.isNotEmpty || results!.projects.isNotEmpty);
  bool get isEmpty =>
      results != null &&
      results!.tasks.isEmpty &&
      results!.projects.isEmpty;
}

// ─── Search notifier ──────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchScreenState> {
  final SearchService _service;

  SearchNotifier(this._service) : super(const SearchScreenState());

  Future<void> search({
    required String query,
    String? status,
    String? priority,
  }) async {
    if (query.trim().isEmpty) {
      state = const SearchScreenState();
      return;
    }
    state = state.copyWith(isLoading: true, query: query, error: null);
    try {
      final result = await _service.search(
        q: query.trim(),
        type: 'tasks,projects',
        status: status,
        priority: priority,
      );
      state = state.copyWith(isLoading: false, results: result);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() => state = const SearchScreenState();
}

final _searchScreenProvider = StateNotifierProvider.autoDispose<
    SearchNotifier, SearchScreenState>((ref) {
  return SearchNotifier(ref.watch(searchServiceProvider));
});

// ─── Filter type enum ─────────────────────────────────────────────────────────

enum SearchFilter { all, status, priority, assignee, dueDate }

// ─── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  SearchFilter _activeFilter = SearchFilter.all;

  final Set<TaskStatus> _selectedStatuses = {};
  final Set<TaskPriority> _selectedPriorities = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    setState(() {}); // update clear button visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch();
    });
  }

  void _runSearch() {
    final q = _searchController.text;
    final status = _selectedStatuses.isNotEmpty
        ? _selectedStatuses.map((s) => s.value).join(',')
        : null;
    final priority = _selectedPriorities.isNotEmpty
        ? _selectedPriorities.map((p) => p.value).join(',')
        : null;
    ref.read(_searchScreenProvider.notifier).search(
          query: q,
          status: status,
          priority: priority,
        );
  }

  void _onFilterTapped(SearchFilter filter) {
    if (filter == SearchFilter.all) {
      setState(() {
        _activeFilter = SearchFilter.all;
        _selectedStatuses.clear();
        _selectedPriorities.clear();
      });
      _runSearch();
    } else {
      _showFilterSheet(filter);
    }
  }

  void _showFilterSheet(SearchFilter initialFilter) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _FilterSheet(
        initialFilter: initialFilter,
        selectedStatuses: _selectedStatuses,
        selectedPriorities: _selectedPriorities,
        onApply: (statuses, priorities) {
          setState(() {
            _selectedStatuses
              ..clear()
              ..addAll(statuses);
            _selectedPriorities
              ..clear()
              ..addAll(priorities);
            _activeFilter = initialFilter;
          });
          _runSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final searchState = ref.watch(_searchScreenProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: context.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              _buildFilterRow(isDark),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(searchState, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: _onQueryChanged,
                style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks & projects...',
                  hintStyle: TextStyle(
                    color: context.textSecondaryColor,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: context.textSecondaryColor,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: context.textSecondaryColor,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(_searchScreenProvider.notifier).clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip('All', SearchFilter.all, isDark),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Status',
              SearchFilter.status,
              isDark,
              hasSelection: _selectedStatuses.isNotEmpty,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Priority',
              SearchFilter.priority,
              isDark,
              hasSelection: _selectedPriorities.isNotEmpty,
            ),
            const SizedBox(width: 8),
            _buildFilterChip('Assignee', SearchFilter.assignee, isDark),
            const SizedBox(width: 8),
            _buildFilterChip('Due Date', SearchFilter.dueDate, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    SearchFilter filter,
    bool isDark, {
    bool hasSelection = false,
  }) {
    final isSelected = _activeFilter == filter;
    return GestureDetector(
      onTap: () => _onFilterTapped(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : isDark
                  ? AppTheme.darkCard
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : hasSelection
                    ? AppTheme.primaryColor.withValues(alpha: 0.5)
                    : isDark
                        ? AppTheme.darkBorder
                        : AppTheme.borderColor,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : hasSelection
                        ? AppTheme.primaryColor
                        : context.textSecondaryColor,
                fontWeight: isSelected || hasSelection
                    ? FontWeight.w600
                    : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            if (hasSelection && !isSelected) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SearchScreenState state, bool isDark) {
    if (state.query.isEmpty) {
      return const EmptyState(
        icon: Icons.search_rounded,
        title: 'Search anything',
        subtitle: 'Find tasks, projects and more',
      );
    }
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }
    if (state.error != null) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'Search failed',
        subtitle: state.error,
        actionLabel: 'Retry',
        onAction: _runSearch,
      );
    }
    if (state.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        subtitle: 'Try different keywords or filters',
      );
    }
    if (state.results != null) {
      return _buildResults(state.results!, isDark);
    }
    return const SizedBox.shrink();
  }

  Widget _buildResults(SearchResult results, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        if (results.tasks.isNotEmpty) ...[
          _buildSectionHeader('Tasks', results.tasks.length),
          const SizedBox(height: 10),
          ...results.tasks.asMap().entries.map(
                (entry) => AnimatedListItem(
                  index: entry.key,
                  child: _TaskResultCard(task: entry.value, isDark: isDark),
                ),
              ),
          const SizedBox(height: 20),
        ],
        if (results.projects.isNotEmpty) ...[
          _buildSectionHeader('Projects', results.projects.length),
          const SizedBox(height: 10),
          ...results.projects.asMap().entries.map(
                (entry) => AnimatedListItem(
                  index: entry.key,
                  child: _ProjectResultCard(
                    project: entry.value,
                    isDark: isDark,
                  ),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
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
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Task result card ─────────────────────────────────────────────────────────

class _TaskResultCard extends StatelessWidget {
  final Task task;
  final bool isDark;

  const _TaskResultCard({required this.task, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(task.status.value);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.status.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.folder_outlined,
                      size: 11,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        task.projectId,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.textSecondaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PriorityBadge(priority: task.priority, compact: true),
        ],
      ),
    );
  }
}

// ─── Project result card ──────────────────────────────────────────────────────

class _ProjectResultCard extends StatelessWidget {
  final Project project;
  final bool isDark;

  const _ProjectResultCard({required this.project, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
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
            child: Center(
              child: Text(
                project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimaryColor,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 12,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${project.memberCount} members',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.task_alt_rounded,
                      size: 12,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${project.taskCount} tasks',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.textSecondaryColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ─── Filter bottom sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final SearchFilter initialFilter;
  final Set<TaskStatus> selectedStatuses;
  final Set<TaskPriority> selectedPriorities;
  final void Function(Set<TaskStatus>, Set<TaskPriority>) onApply;

  const _FilterSheet({
    required this.initialFilter,
    required this.selectedStatuses,
    required this.selectedPriorities,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<TaskStatus> _statuses;
  late Set<TaskPriority> _priorities;

  @override
  void initState() {
    super.initState();
    _statuses = Set.from(widget.selectedStatuses);
    _priorities = Set.from(widget.selectedPriorities);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),
          // Status multi-select
          Text(
            'STATUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TaskStatus.values.map((s) {
              final selected = _statuses.contains(s);
              final color = AppTheme.statusColor(s.value);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _statuses.remove(s);
                  } else {
                    _statuses.add(s);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : isDark
                            ? AppTheme.darkCardAlt
                            : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : context.borderPrimary,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    s.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected ? color : context.textSecondaryColor,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Priority multi-select
          Text(
            'PRIORITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondaryColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TaskPriority.values.map((p) {
              final selected = _priorities.contains(p);
              final color = AppTheme.priorityColor(p.value);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _priorities.remove(p);
                  } else {
                    _priorities.add(p);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : isDark
                            ? AppTheme.darkCardAlt
                            : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : context.borderPrimary,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: selected ? color : context.textSecondaryColor,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _statuses.clear();
                      _priorities.clear();
                    });
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkCardAlt
                          : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderPrimary),
                    ),
                    child: Center(
                      child: Text(
                        'Clear All',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    widget.onApply(_statuses, _priorities);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                    ),
                    child: const Center(
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
