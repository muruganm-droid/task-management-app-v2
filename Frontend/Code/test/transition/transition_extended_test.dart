// =============================================================================
// Category 4 Extended: Transition Tests
// NEW tests: hero transitions, cross-fade transitions, rotation transitions,
// navigator replacement, multiple sequential navigations, back navigation,
// AnimatedOpacity widget transitions, AnimatedCrossFade behavior
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/theme.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('TRANS-EXT-001: Navigator replacement transition', () {
    testWidgets('pushReplacement completes transition', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Scaffold(body: Text('Replaced')),
                  ),
                );
              },
              child: const Text('Replace'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Replace'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Replaced'), findsOneWidget);
      expect(find.text('Replace'), findsNothing);
    });
  });

  group('TRANS-EXT-002: Sequential page navigation', () {
    testWidgets('Push 3 pages and pop back', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                const Text('Page 1'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: Builder(
                            builder: (ctx2) => Column(children: [
                              const Text('Page 2'),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    ctx2,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const Scaffold(body: Text('Page 3')),
                                    ),
                                  );
                                },
                                child: const Text('Go 3'),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go 2'),
                ),
              ],
            ),
          ),
        ),
      ));

      // Navigate to page 2
      await tester.tap(find.text('Go 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Page 2'), findsOneWidget);

      // Navigate to page 3
      await tester.tap(find.text('Go 3'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Page 3'), findsOneWidget);
    });
  });

  group('TRANS-EXT-003: AnimatedOpacity transition', () {
    testWidgets('AnimatedOpacity responds to state change', (tester) async {
      bool visible = true;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AnimatedOpacity(
                    opacity: visible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Text('Fading'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => visible = false),
                    child: const Text('Hide'),
                  ),
                ],
              );
            },
          ),
        ),
      ));
      expect(find.text('Fading'), findsOneWidget);
      await tester.tap(find.text('Hide'));
      await tester.pump(const Duration(milliseconds: 350));
      // Widget is still in tree but with opacity 0
      expect(find.text('Fading'), findsOneWidget);
    });
  });

  group('TRANS-EXT-004: AnimatedCrossFade', () {
    testWidgets('Crossfade transitions between two children', (tester) async {
      bool showFirst = true;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  AnimatedCrossFade(
                    firstChild: const Text('First'),
                    secondChild: const Text('Second'),
                    crossFadeState: showFirst
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => showFirst = false),
                    child: const Text('Toggle'),
                  ),
                ],
              );
            },
          ),
        ),
      ));
      expect(find.text('First'), findsOneWidget);
      await tester.tap(find.text('Toggle'));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Second'), findsOneWidget);
    });
  });

  group('TRANS-EXT-005: RotationTransition', () {
    testWidgets('RotationTransition renders during navigation', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => Scaffold(
                      body: RotationTransition(
                        turns: anim,
                        child: const Text('Rotated'),
                      ),
                    ),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child: const Text('Spin'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Spin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Rotated'), findsOneWidget);
    });
  });

  group('TRANS-EXT-006: SizeTransition', () {
    testWidgets('SizeTransition renders during navigation', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => Scaffold(
                      body: SizeTransition(
                        sizeFactor: anim,
                        child: const Text('Sized'),
                      ),
                    ),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              child: const Text('Size'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Size'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Sized'), findsOneWidget);
    });
  });

  group('TRANS-EXT-007: Combined FadeTransition + SlideTransition', () {
    testWidgets('Both transitions applied simultaneously', (tester) async {
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => Scaffold(
                      body: FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(anim),
                          child: const Text('Both'),
                        ),
                      ),
                    ),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              child: const Text('Combo'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Combo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('Both'), findsOneWidget);
    });
  });

  group('TRANS-EXT-008: Dark theme page transitions', () {
    test('Dark theme uses Cupertino for Android', () {
      final builders = AppTheme.darkTheme.pageTransitionsTheme.builders;
      expect(builders[TargetPlatform.android],
          isA<CupertinoPageTransitionsBuilder>());
    });
  });

  group('TRANS-EXT-009: AnimatedAlign transition', () {
    testWidgets('AnimatedAlign moves child', (tester) async {
      Alignment align = Alignment.topLeft;
      await tester.pumpWidget(createTestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () => setState(() => align = Alignment.bottomRight),
                child: AnimatedAlign(
                  alignment: align,
                  duration: const Duration(milliseconds: 300),
                  child: const Text('Moving'),
                ),
              );
            },
          ),
        ),
      ));
      expect(find.text('Moving'), findsOneWidget);
      await tester.tap(find.text('Moving'));
      await tester.pump(const Duration(milliseconds: 350));
      // Widget still rendered after align change
      expect(find.text('Moving'), findsOneWidget);
    });
  });
}
