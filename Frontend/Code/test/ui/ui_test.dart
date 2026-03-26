// =============================================================================
// Category 1: UI Tests
// Tests: Widget rendering, theme correctness, layout integrity, dark/light mode
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/theme.dart';
import 'package:task_management_app/presentation/views/widgets/priority_badge.dart';
import 'package:task_management_app/presentation/views/widgets/status_badge.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';
import 'package:task_management_app/presentation/views/widgets/shimmer_list.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import 'package:task_management_app/data/models/task.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UI-001: AppTheme', () {
    test('Light theme properties', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
      expect(theme.scaffoldBackgroundColor, AppTheme.surfaceColor);
    });

    test('Dark theme properties', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
      expect(theme.scaffoldBackgroundColor, AppTheme.darkSurface);
    });

    test('Color constants defined', () {
      expect(AppTheme.primaryColor, const Color(0xFF6366F1));
      expect(AppTheme.errorColor, const Color(0xFFEF4444));
      expect(AppTheme.successColor, const Color(0xFF10B981));
      expect(AppTheme.warningColor, const Color(0xFFF59E0B));
    });

    test('Priority colors', () {
      expect(AppTheme.priorityColor('CRITICAL'), const Color(0xFFEF4444));
      expect(AppTheme.priorityColor('HIGH'), const Color(0xFFF97316));
      expect(AppTheme.priorityColor('MEDIUM'), const Color(0xFFF59E0B));
      expect(AppTheme.priorityColor('LOW'), const Color(0xFF10B981));
      expect(AppTheme.priorityColor('UNKNOWN'), const Color(0xFF6B7280));
    });

    test('Status colors', () {
      expect(AppTheme.statusColor('TODO'), const Color(0xFF6B7280));
      expect(AppTheme.statusColor('IN_PROGRESS'), const Color(0xFF3B82F6));
      expect(AppTheme.statusColor('DONE'), const Color(0xFF10B981));
    });

    test('Glow shadow', () {
      final shadows = AppTheme.glowShadow(Colors.red);
      expect(shadows.length, 1);
      expect(shadows[0].blurRadius, 20);
    });
  });

  group('UI-002: ThemeContextExtension', () {
    testWidgets('Light theme context', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          expect(context.isDark, false);
          expect(context.surfacePrimary, AppTheme.surfaceColor);
          expect(context.cardSurface, AppTheme.cardColor);
          return const SizedBox();
        }),
      ));
    });

    testWidgets('Dark theme context', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (context) {
          expect(context.isDark, true);
          expect(context.surfacePrimary, AppTheme.darkSurface);
          expect(context.cardSurface, AppTheme.darkCard);
          return const SizedBox();
        }),
      ));
    });
  });

  group('UI-003: PriorityBadge', () {
    testWidgets('Renders all priorities', (tester) async {
      for (final p in TaskPriority.values) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(body: Center(child: PriorityBadge(priority: p))),
        ));
        expect(find.text(p.displayName), findsOneWidget);
      }
    });

    testWidgets('Compact mode renders', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(
            child: PriorityBadge(priority: TaskPriority.high, compact: true),
          ),
        ),
      ));
      expect(find.text('High'), findsOneWidget);
    });
  });

  group('UI-004: StatusBadge', () {
    testWidgets('Renders all statuses', (tester) async {
      for (final s in TaskStatus.values) {
        await tester.pumpWidget(createTestApp(
          child: Scaffold(body: Center(child: StatusBadge(status: s))),
        ));
        expect(find.text(s.displayName), findsOneWidget);
      }
    });
  });

  group('UI-005: EmptyState', () {
    testWidgets('Renders title and subtitle', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            subtitle: 'Add some',
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add some'), findsOneWidget);
    });

    testWidgets('Renders action button', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'No items',
            actionLabel: 'Add',
            onAction: () {},
          ),
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Add'), findsOneWidget);
    });
  });

  group('UI-006: ShimmerTaskList', () {
    testWidgets('Renders CreativeLoader', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: ShimmerTaskList(itemCount: 3)),
      ));
      await tester.pump();
      expect(find.byType(ShimmerTaskList), findsOneWidget);
    });
  });

  group('UI-007: GlassmorphicContainer', () {
    testWidgets('Renders in both themes', (tester) async {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(createTestAppWithTheme(
          theme: theme,
          child: const Scaffold(
            body: Center(
              child: GlassmorphicContainer(child: Text('Glass')),
            ),
          ),
        ));
        expect(find.text('Glass'), findsOneWidget);
      }
    });
  });

  group('UI-008: TaskCard', () {
    testWidgets('Renders task info', (tester) async {
      final task = createTestTask(
        title: 'Fix bug',
        description: 'Login page issue',
        priority: TaskPriority.high,
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: TaskCard(task: task)),
      ));
      await tester.pump();
      expect(find.text('Fix bug'), findsOneWidget);
      expect(find.text('Login page issue'), findsOneWidget);
    });

    testWidgets('Renders due date', (tester) async {
      final task = createTestTask(
        title: 'Due task',
        dueDate: DateTime(2024, 12, 25),
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
      expect(find.text('Dec 25'), findsOneWidget);
    });

    testWidgets('Renders subtask count', (tester) async {
      final task = createTestTask(
        title: 'Subtask task',
        subTasks: [
          createTestSubTask(id: 's-1', isDone: true),
          createTestSubTask(id: 's-2', isDone: false),
        ],
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
      expect(find.text('1/2'), findsOneWidget);
    });
  });

  group('UI-009: Input decoration themes', () {
    test('Light theme border radius', () {
      final border = AppTheme.lightTheme.inputDecorationTheme.border
          as OutlineInputBorder;
      expect(border.borderRadius, BorderRadius.circular(14));
    });

    test('Dark theme fill', () {
      expect(AppTheme.darkTheme.inputDecorationTheme.fillColor,
          AppTheme.darkCard);
      expect(AppTheme.darkTheme.inputDecorationTheme.filled, true);
    });
  });

  group('UI-010: Page transition themes', () {
    test('Light theme uses Cupertino transitions', () {
      final builders =
          AppTheme.lightTheme.pageTransitionsTheme.builders;
      expect(builders[TargetPlatform.iOS],
          isA<CupertinoPageTransitionsBuilder>());
      expect(builders[TargetPlatform.android],
          isA<CupertinoPageTransitionsBuilder>());
    });
  });
}
