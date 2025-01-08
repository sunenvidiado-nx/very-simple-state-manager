import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

class _TestStateManager extends StateManager<int> {
  _TestStateManager() : super(0);

  void increment() => state++;
}

class _TestWidget extends ManagedStatefulWidget<_TestStateManager, int> {
  const _TestWidget({super.autoDispose = true});

  @override
  _TestStateManager createStateManager() => _TestStateManager();

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState
    extends ManagedState<_TestStateManager, int, _TestWidget> {
  @override
  Widget build(BuildContext context) {
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
  group('ManagedStatefulWidget', () {
    testWidgets('should display initial state', (tester) async {
      await tester.pumpWidget(const _TestWidget());
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should update state when button is pressed', (tester) async {
      await tester.pumpWidget(const _TestWidget());

      await tester.tap(find.byType(TextButton));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should update state through state manager', (tester) async {
      await tester.pumpWidget(const _TestWidget());

      final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
      state.stateManager.increment();
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should dispose state manager when autoDispose is true',
        (tester) async {
      await tester.pumpWidget(const _TestWidget(autoDispose: true));

      final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
      final stateManager = state.stateManager;

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      // Try to use disposed state manager
      expect(
        () => stateManager.increment(),
        throwsFlutterError,
      );
    });

    testWidgets('should not dispose state manager when autoDispose is false',
        (tester) async {
      await tester.pumpWidget(const _TestWidget(autoDispose: false));

      final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
      final stateManager = state.stateManager;

      // Remove widget from tree
      await tester.pumpWidget(const SizedBox());

      // State manager should still be usable
      expect(
        () => stateManager.increment(),
        returnsNormally,
      );

      // Clean up
      stateManager.dispose();
    });
  });
}
