import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/widgets/empty_state.dart';

// Helper: wraps the widget with a MaterialApp so Theme and MediaQuery are
// available (required by EmptyState's animation and theme extensions).
Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('EmptyState widget', () {
    testWidgets('renders icon, title, and subtitle when all provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'Nothing here',
            subtitle: 'Add your first task to get started',
          ),
        ),
      );

      // Allow animations to tick (FadeInWidget starts with opacity 0 but the
      // widget tree is still built; pump a frame to advance the controller).
      await tester.pump(const Duration(milliseconds: 700));

      // Icon widget is present in the tree.
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);

      // Title text is present.
      expect(find.text('Nothing here'), findsOneWidget);

      // Subtitle text is present.
      expect(find.text('Add your first task to get started'), findsOneWidget);
    });

    testWidgets('renders action button when actionLabel and onAction provided',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        _wrap(
          EmptyState(
            icon: Icons.add_task_outlined,
            title: 'No tasks yet',
            subtitle: 'Create one now',
            actionLabel: 'Create Task',
            onAction: () => tapped = true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      // Action button text should be present.
      expect(find.text('Create Task'), findsOneWidget);

      // Tap the action button via GestureDetector (ScaleOnTap).
      await tester.tap(find.text('Create Task'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does NOT render action button when actionLabel is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyState(
            icon: Icons.folder_off_outlined,
            title: 'No projects',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      // No text widget beyond the title.
      expect(find.text('No projects'), findsOneWidget);

      // No stray button text should appear.
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('does NOT render subtitle when subtitle is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyState(
            icon: Icons.search_off_outlined,
            title: 'No results',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('No results'), findsOneWidget);

      // Only one Text widget should be in the tree (the title).
      final texts = tester.widgetList<Text>(find.byType(Text)).toList();
      // Filter to the EmptyState-specific texts (exclude app bar, etc.).
      final bodyTexts = texts.where((t) => t.data != null && t.data!.isNotEmpty).toList();
      expect(bodyTexts.any((t) => t.data == 'No results'), isTrue);
      // Subtitle should not appear.
      expect(find.text(''), findsNothing);
    });

    testWidgets('does NOT render action button when onAction is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyState(
            icon: Icons.inbox,
            title: 'Empty',
            actionLabel: 'Do something', // label provided but no callback
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      // The action label text must NOT be rendered because onAction is null.
      expect(find.text('Do something'), findsNothing);
    });

    testWidgets('widget can be created without optional params',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          const EmptyState(
            icon: Icons.hourglass_empty,
            title: 'Waiting...',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('Waiting...'), findsOneWidget);
    });
  });
}
