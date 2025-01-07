import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/simple_state_manager.dart';

class _TestStateManager extends StateManager<String> {
  _TestStateManager() : super('initial');

  void updateText(String newText) {
    state = newText;
  }
}

void main() {
  group('StateBuilder', () {
    late _TestStateManager manager;

    setUp(() {
      manager = _TestStateManager();
    });

    tearDown(() {
      manager.dispose();
    });

    group('Should display correct text', () {
      testWidgets('when initially built', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StateBuilder(
              stateManager: manager,
              builder: (context, state) => Text(state),
            ),
          ),
        );

        expect(find.text('initial'), findsOneWidget);
      });

      testWidgets('when state changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StateBuilder(
              stateManager: manager,
              builder: (context, state) => Text(state),
            ),
          ),
        );

        manager.updateText('updated');
        await tester.pump();

        expect(find.text('updated'), findsOneWidget);
      });
    });

    group('Should rebuild when state changes', () {
      testWidgets('when state changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: StateBuilder(
              stateManager: manager,
              builder: (context, state) => Text(state),
            ),
          ),
        );

        manager.updateText('updated');
        await tester.pump();

        expect(find.text('updated'), findsOneWidget);
        expect(find.text('initial'), findsNothing);
      });
    });

    group('Should pass correct state to builder function', () {
      testWidgets('when state changes', (tester) async {
        String? capturedState;

        await tester.pumpWidget(
          MaterialApp(
            home: StateBuilder(
              stateManager: manager,
              builder: (context, state) {
                capturedState = state;
                return Text(state);
              },
            ),
          ),
        );

        expect(capturedState, equals('initial'));

        manager.updateText('new state');
        await tester.pump();

        expect(capturedState, equals('new state'));
      });
    });
  });
}
