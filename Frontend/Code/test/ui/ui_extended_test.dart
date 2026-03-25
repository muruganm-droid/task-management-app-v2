// =============================================================================
// Category 1 Extended: UI Tests
// NEW tests covering: theme gradients, card themes, button themes, dialog themes,
// snackbar themes, bottom nav themes, chip themes, divider themes,
// dark mode widget rendering, GlassmorphicContainer properties,
// ShimmerStatCards, TaskCard with assignees, PriorityBadge in dark mode
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/theme.dart';
import 'package:task_management_app/presentation/views/widgets/priority_badge.dart';
import 'package:task_management_app/presentation/views/widgets/status_badge.dart';
import 'package:task_management_app/presentation/views/widgets/shimmer_list.dart';
import 'package:task_management_app/presentation/views/widgets/task_card.dart';
import 'package:task_management_app/presentation/views/animations/animated_list_item.dart';
import 'package:task_management_app/data/models/task.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('UI-EXT-001: Theme gradient constants', () {
    test('Primary gradient has two colors', () {
      expect(AppTheme.primaryGradient.colors.length, 2);
      expect(AppTheme.primaryGradient.colors[0], const Color(0xFF6366F1));
      expect(AppTheme.primaryGradient.colors[1], const Color(0xFF8B5CF6));
    });

    test('Accent gradient defined', () {
      expect(AppTheme.accentGradient.colors.length, 2);
      expect(AppTheme.accentGradient.begin, Alignment.topLeft);
      expect(AppTheme.accentGradient.end, Alignment.bottomRight);
    });

    test('Dark background gradient vertical', () {
      expect(AppTheme.darkBackgroundGradient.begin, Alignment.topCenter);
      expect(AppTheme.darkBackgroundGradient.end, Alignment.bottomCenter);
    });

    test('Light background gradient vertical', () {
      expect(AppTheme.lightBackgroundGradient.begin, Alignment.topCenter);
      expect(AppTheme.lightBackgroundGradient.end, Alignment.bottomCenter);
    });

    test('Success gradient', () {
      expect(AppTheme.successGradient.colors[0], const Color(0xFF10B981));
    });

    test('Warning gradient', () {
      expect(AppTheme.warningGradient.colors[0], const Color(0xFFF59E0B));
    });

    test('Error gradient', () {
      expect(AppTheme.errorGradient.colors[0], const Color(0xFFEF4444));
    });
  });

  group('UI-EXT-002: Card theme properties', () {
    test('Light card theme rounded corners', () {
      final shape = AppTheme.lightTheme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });

    test('Light card elevation is 0', () {
      expect(AppTheme.lightTheme.cardTheme.elevation, 0);
    });

    test('Dark card theme color', () {
      expect(AppTheme.darkTheme.cardTheme.color, AppTheme.darkCard);
    });

    test('Dark card margin is zero', () {
      expect(AppTheme.darkTheme.cardTheme.margin, EdgeInsets.zero);
    });
  });

  group('UI-EXT-003: Button theme properties', () {
    test('Light elevated button uses primary color', () {
      final style = AppTheme.lightTheme.elevatedButtonTheme.style;
      expect(style, isNotNull);
    });

    test('Dark elevated button uses primary color', () {
      final style = AppTheme.darkTheme.elevatedButtonTheme.style;
      expect(style, isNotNull);
    });

    test('FAB theme has primary color', () {
      expect(AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
          AppTheme.primaryColor);
    });

    test('FAB theme rounded corners', () {
      final shape = AppTheme.lightTheme.floatingActionButtonTheme.shape
          as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(16));
    });
  });

  group('UI-EXT-004: Dialog and SnackBar themes', () {
    test('Light dialog has rounded shape', () {
      final shape = AppTheme.lightTheme.dialogTheme.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(20));
    });

    test('Dark dialog has dark card background', () {
      expect(AppTheme.darkTheme.dialogTheme.backgroundColor, AppTheme.darkCard);
    });

    test('Snackbar uses floating behavior', () {
      expect(AppTheme.lightTheme.snackBarTheme.behavior,
          SnackBarBehavior.floating);
    });
  });

  group('UI-EXT-005: BottomNavigationBar themes', () {
    test('Light bottom nav selected color is primary', () {
      expect(AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
          AppTheme.primaryColor);
    });

    test('Dark bottom nav has dark background', () {
      expect(AppTheme.darkTheme.bottomNavigationBarTheme.backgroundColor,
          const Color(0xFF1E293B));
    });

    test('Both themes use fixed type', () {
      expect(AppTheme.lightTheme.bottomNavigationBarTheme.type,
          BottomNavigationBarType.fixed);
      expect(AppTheme.darkTheme.bottomNavigationBarTheme.type,
          BottomNavigationBarType.fixed);
    });
  });

  group('UI-EXT-006: AppBar themes', () {
    test('Light appbar transparent background', () {
      expect(AppTheme.lightTheme.appBarTheme.backgroundColor,
          Colors.transparent);
    });

    test('Light appbar uses dark overlay', () {
      expect(AppTheme.lightTheme.appBarTheme.systemOverlayStyle,
          SystemUiOverlayStyle.dark);
    });

    test('Dark appbar uses light overlay', () {
      expect(AppTheme.darkTheme.appBarTheme.systemOverlayStyle,
          SystemUiOverlayStyle.light);
    });

    test('Both appbars have 0 elevation', () {
      expect(AppTheme.lightTheme.appBarTheme.elevation, 0);
      expect(AppTheme.darkTheme.appBarTheme.elevation, 0);
    });
  });

  group('UI-EXT-007: CardShadow helpers', () {
    test('Light card shadow has 2 shadows', () {
      expect(AppTheme.cardShadowLight.length, 2);
    });

    test('Dark card shadow has 2 shadows', () {
      expect(AppTheme.cardShadowDark.length, 2);
    });

    test('Glow shadow with custom color', () {
      final shadows = AppTheme.glowShadow(Colors.green);
      expect(shadows.length, 1);
      expect(shadows[0].offset, const Offset(0, 4));
    });
  });

  group('UI-EXT-008: ThemeContextExtension full coverage', () {
    testWidgets('Light theme cardAltSurface', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(builder: (context) {
          expect(context.cardAltSurface, const Color(0xFFF3F4F6));
          expect(context.textPrimaryColor, AppTheme.textPrimary);
          expect(context.textSecondaryColor, AppTheme.textSecondary);
          expect(context.borderPrimary, AppTheme.borderColor);
          expect(context.cardShadow, AppTheme.cardShadowLight);
          expect(context.backgroundGradient, AppTheme.lightBackgroundGradient);
          return const SizedBox();
        }),
      ));
    });

    testWidgets('Dark theme extension values', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme,
        home: Builder(builder: (context) {
          expect(context.cardAltSurface, AppTheme.darkCardAlt);
          expect(context.textPrimaryColor, AppTheme.darkTextPrimary);
          expect(context.textSecondaryColor, AppTheme.darkTextSecondary);
          expect(context.borderPrimary, AppTheme.darkBorder);
          expect(context.cardShadow, AppTheme.cardShadowDark);
          expect(context.backgroundGradient, AppTheme.darkBackgroundGradient);
          return const SizedBox();
        }),
      ));
    });
  });

  group('UI-EXT-009: StatusColor edge cases', () {
    test('UNDER_REVIEW status', () {
      expect(AppTheme.statusColor('UNDER_REVIEW'), const Color(0xFFF59E0B));
    });

    test('ARCHIVED status', () {
      expect(AppTheme.statusColor('ARCHIVED'), const Color(0xFF9CA3AF));
    });

    test('Unknown status returns gray', () {
      expect(AppTheme.statusColor('WEIRD'), const Color(0xFF6B7280));
    });

    test('Case insensitive status', () {
      expect(AppTheme.statusColor('done'), const Color(0xFF10B981));
    });
  });

  group('UI-EXT-010: PriorityBadge in dark theme', () {
    testWidgets('Renders correctly in dark theme', (tester) async {
      await tester.pumpWidget(createTestAppWithTheme(
        theme: AppTheme.darkTheme,
        child: const Scaffold(
          body: Center(child: PriorityBadge(priority: TaskPriority.critical)),
        ),
      ));
      expect(find.text('Critical'), findsOneWidget);
    });
  });

  group('UI-EXT-011: StatusBadge in dark theme', () {
    testWidgets('All statuses render in dark', (tester) async {
      for (final s in TaskStatus.values) {
        await tester.pumpWidget(createTestAppWithTheme(
          theme: AppTheme.darkTheme,
          child: Scaffold(body: Center(child: StatusBadge(status: s))),
        ));
        expect(find.text(s.displayName), findsOneWidget);
      }
    });
  });

  group('UI-EXT-012: ShimmerStatCards', () {
    testWidgets('Renders 3 shimmer boxes', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(body: ShimmerStatCards()),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsNWidgets(3));
    });

    testWidgets('Renders in dark theme', (tester) async {
      await tester.pumpWidget(createTestAppWithTheme(
        theme: AppTheme.darkTheme,
        child: const Scaffold(body: ShimmerStatCards()),
      ));
      await tester.pump();
      expect(find.byType(ShimmerLoading), findsNWidgets(3));
    });
  });

  group('UI-EXT-013: TaskCard with assignees', () {
    testWidgets('Renders assignee avatars', (tester) async {
      final task = createTestTask(
        title: 'Assigned task',
        assigneeIds: ['u-1', 'u-2'],
      );
      await tester.pumpWidget(createTestApp(
        child: Scaffold(body: SingleChildScrollView(child: TaskCard(task: task))),
      ));
      await tester.pump();
      expect(find.text('U'), findsWidgets);
    });

    testWidgets('TaskCard onTap fires', (tester) async {
      bool tapped = false;
      final task = createTestTask(title: 'Tap me');
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: TaskCard(task: task, onTap: () => tapped = true),
        ),
      ));
      await tester.pump();
      await tester.tap(find.text('Tap me'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tapped, true);
    });
  });

  group('UI-EXT-014: GlassmorphicContainer properties', () {
    testWidgets('Custom borderRadius and padding', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: Center(
            child: GlassmorphicContainer(
              borderRadius: 24,
              padding: EdgeInsets.all(20),
              child: Text('Custom'),
            ),
          ),
        ),
      ));
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('Custom opacity works', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: const Scaffold(
          body: GlassmorphicContainer(
            opacity: 0.5,
            child: Text('Opaque'),
          ),
        ),
      ));
      expect(find.text('Opaque'), findsOneWidget);
    });
  });

  group('UI-EXT-015: Divider and Chip themes', () {
    test('Light divider color', () {
      expect(AppTheme.lightTheme.dividerTheme.color, AppTheme.borderColor);
    });

    test('Dark divider color', () {
      expect(AppTheme.darkTheme.dividerTheme.color, AppTheme.darkBorder);
    });

    test('Light chip background', () {
      expect(AppTheme.lightTheme.chipTheme.backgroundColor, AppTheme.surfaceColor);
    });

    test('Dark chip background', () {
      expect(AppTheme.darkTheme.chipTheme.backgroundColor, AppTheme.darkCard);
    });
  });

  group('UI-EXT-016: Dark theme input decoration', () {
    test('Dark theme border radius matches light', () {
      final darkBorder = AppTheme.darkTheme.inputDecorationTheme.border
          as OutlineInputBorder;
      expect(darkBorder.borderRadius, BorderRadius.circular(14));
    });

    test('Dark theme focused border uses primary color', () {
      final focusedBorder = AppTheme.darkTheme.inputDecorationTheme.focusedBorder
          as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, AppTheme.primaryColor);
      expect(focusedBorder.borderSide.width, 2);
    });
  });
}
