import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

class _TestStateManager extends StateManager<int> {
  _TestStateManager() : super(0);

  void increment() => state++;
}

class _TestWidget extends ManagedWidget<_TestStateManager, int> {
  _TestWidget({super.autoDispose = true});

  late final stateManager = _TestStateManager();

  @override
  _TestStateManager createStateManager() => stateManager;

  @override
  Widget build(BuildContext context, int state) {
    return MaterialApp(
      home: Column(
        children: [
          Text(state.toString()),
          TextButton(
            onPressed: () => stateManager.increment(),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}

void main() {
  group('ManagedWidget', () {
    testWidgets('should display initial state', (tester) async {
      await tester.pumpWidget(_TestWidget());
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should update state when button is pressed', (tester) async {
      await tester.pumpWidget(_TestWidget());

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should dispose state manager when autoDispose is true',
        (tester) async {
      final widget = _TestWidget();
      await tester.pumpWidget(widget);

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      // Try to use disposed state manager
      expect(
        () => widget.stateManager.increment(),
        throwsFlutterError,
      );
    });

    testWidgets('should not dispose state manager when autoDispose is false',
        (tester) async {
      final widget = _TestWidget(autoDispose: false);
      await tester.pumpWidget(widget);

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      // State manager should still be usable
      expect(
        () => widget.stateManager.increment(),
        returnsNormally,
      );

      // Clean up
      widget.stateManager.dispose();
    });
  });
}
