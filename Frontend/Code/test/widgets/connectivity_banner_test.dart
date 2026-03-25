import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/presentation/views/widgets/connectivity_banner.dart';

void main() {
  group('ConnectivityBanner widget', () {
    // Helper: builds the widget tree with Riverpod and overrides the
    // connectivity stream so no real platform channel is touched.
    Widget buildBanner({
      Stream<List<ConnectivityResult>>? connectivityStream,
    }) {
      final stream =
          connectivityStream ?? const Stream<List<ConnectivityResult>>.empty();

      return ProviderScope(
        overrides: [
          connectivityStreamProvider.overrideWith(
            (ref) => stream,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ConnectivityBanner(),
          ),
        ),
      );
    }

    testWidgets('can be instantiated without throwing', (tester) async {
      await tester.pumpWidget(buildBanner());
      await tester.pump();

      // The widget should exist in the tree (as SizedBox.shrink when no
      // connectivity event has fired yet).
      expect(find.byType(ConnectivityBanner), findsOneWidget);
    });

    testWidgets('is initially invisible (SizedBox.shrink) before any event',
        (tester) async {
      await tester.pumpWidget(buildBanner());
      await tester.pump();

      // No banner content visible – the widget renders SizedBox.shrink.
      expect(find.text('No internet connection'), findsNothing);
      expect(find.text('Connection restored'), findsNothing);
    });

    testWidgets('shows offline banner when connectivity is none',
        (tester) async {
      final controller =
          StreamController<List<ConnectivityResult>>.broadcast();

      await tester.pumpWidget(
          buildBanner(connectivityStream: controller.stream));
      await tester.pump();

      // Emit an offline event.
      controller.add([ConnectivityResult.none]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('No internet connection'), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows restored banner when reconnected after offline',
        (tester) async {
      final controller =
          StreamController<List<ConnectivityResult>>.broadcast();

      await tester.pumpWidget(
          buildBanner(connectivityStream: controller.stream));
      await tester.pump();

      // First go offline.
      controller.add([ConnectivityResult.none]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Then reconnect.
      controller.add([ConnectivityResult.wifi]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Connection restored'), findsOneWidget);

      await controller.close();
    });
  });
}
