import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  group('SelectedStateBuilder', () {
    late TestStateManager stateManager;

    setUp(() {
      stateManager = TestStateManager();
    });

    testWidgets('should build with initial selected state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) => state.name,
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
    });

    testWidgets('should rebuild when selected value changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) => state.name,
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);

      stateManager.updateName('updated');
      await tester.pump();

      expect(find.text('updated'), findsOneWidget);
    });

    testWidgets('should not rebuild when unselected value changes',
        (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) => state.name,
            builder: (context, name) {
              buildCount++;
              return Text(name);
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('initial'), findsOneWidget);

      // Update count (unselected value)
      stateManager.updateCount(42);
      await tester.pump();

      // Build count should not increase since we're only watching name
      expect(buildCount, 1);
      expect(find.text('initial'), findsOneWidget);
    });

    testWidgets('should handle null values correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, int?>(
            stateManager: stateManager,
            selector: (state) => state.nullableValue,
            builder: (context, value) => Text(value?.toString() ?? 'null'),
          ),
        ),
      );

      expect(find.text('null'), findsOneWidget);

      stateManager.updateNullableValue(42);
      await tester.pump();

      expect(find.text('42'), findsOneWidget);

      stateManager.updateNullableValue(null);
      await tester.pump();

      expect(find.text('null'), findsOneWidget);
    });

    testWidgets(
      'should use custom equals function when provided',
      (tester) async {
        int buildCount = 0;
        bool equalsWasCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SelectedStateBuilder<TestStateManager, TestState, String>(
              stateManager: stateManager,
              selector: (state) => state.name,
              equals: (prev, next) {
                equalsWasCalled = true;
                return prev.toLowerCase() == next.toLowerCase();
              },
              builder: (context, name) {
                buildCount++;
                return Text(name);
              },
            ),
          ),
        );

        expect(buildCount, 1);
        expect(equalsWasCalled, false); // Not called on first build
        expect(find.text('initial'), findsOneWidget);

        // Update with same value but different case
        stateManager.updateName('INITIAL');
        await tester.pump();

        expect(equalsWasCalled, true);
        expect(buildCount, 1); // Should not rebuild due to custom equals
        expect(find.text('initial'),
            findsOneWidget); // Should still show old value since we didn't rebuild
      },
    );

    testWidgets('should handle errors in selector gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) {
              throw Exception('Selector error');
            },
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(tester.takeException(), isInstanceOf<Exception>());
    });

    testWidgets('should handle state manager updates correctly',
        (tester) async {
      final secondStateManager = TestStateManager();
      secondStateManager.updateName('second');

      final widget = MaterialApp(
        home: SelectedStateBuilder<TestStateManager, TestState, String>(
          stateManager: stateManager,
          selector: (state) => state.name,
          builder: (context, name) => Text(name),
        ),
      );

      await tester.pumpWidget(widget);
      expect(find.text('initial'), findsOneWidget);

      // Update widget with new state manager
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: secondStateManager,
            selector: (state) => state.name,
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('should handle builder errors gracefully', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) => state.name,
            builder: (context, name) {
              throw Exception('Builder error');
            },
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is ErrorWidget &&
              widget.message.contains(
                'Error building SelectedStateBuilder: Exception: Builder error',
              ),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'should handle selector errors during state change',
      (tester) async {
        final key = GlobalKey();

        await tester.pumpWidget(
          MaterialApp(
            home: SelectedStateBuilder<TestStateManager, TestState, String>(
              key: key,
              stateManager: stateManager,
              selector: (state) => state.name,
              builder: (context, name) => Text(name),
            ),
          ),
        );

        expect(find.text('initial'), findsOneWidget);

        // Replace selector with one that throws
        await tester.pumpWidget(
          MaterialApp(
            home: SelectedStateBuilder<TestStateManager, TestState, String>(
              key: key,
              stateManager: stateManager,
              selector: (state) {
                if (state.name != 'initial') {
                  throw Exception('Selector error during update');
                }
                return state.name;
              },
              builder: (context, name) => Text(name),
            ),
          ),
        );

        // Trigger state change and expect error
        stateManager.updateName('new name');
        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        final dynamic exception = tester.takeException();
        expect(exception, isInstanceOf<Exception>());
        expect(exception.toString(), contains('Selector error during update'));
      },
    );

    testWidgets('should handle errors in onStateChanged', (tester) async {
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            key: key,
            stateManager: stateManager,
            selector: (state) => state.name,
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);

      // Replace selector with one that throws
      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            key: key,
            stateManager: stateManager,
            selector: (state) {
              if (state.name != 'initial') {
                throw Exception('Selector error in onStateChanged');
              }
              return state.name;
            },
            builder: (context, name) => Text(name),
          ),
        ),
      );

      // Trigger state change and expect error
      stateManager.updateName('new name');
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      final dynamic exception = tester.takeException();
      expect(exception, isInstanceOf<Exception>());
      expect(
          exception.toString(), contains('Selector error in onStateChanged'));
    });

    testWidgets('should rebuild when selector throws', (tester) async {
      bool shouldThrow = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, String>(
            stateManager: stateManager,
            selector: (state) {
              if (shouldThrow) {
                throw Exception('Selector error');
              }
              return state.name;
            },
            builder: (context, name) => Text(name),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);

      // Make selector throw and trigger rebuild
      shouldThrow = true;
      stateManager.updateName('new name');
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      final dynamic exception = tester.takeException();
      expect(exception, isInstanceOf<Exception>());
      expect(exception.toString(), contains('Selector error'));
    });
  });
}

class TestState {
  final String name;
  final int count;
  final int? nullableValue;

  TestState({
    this.name = 'initial',
    this.count = 0,
    this.nullableValue,
  });

  TestState copyWith({
    String? name,
    int? count,
    int? nullableValue,
  }) {
    return TestState(
      name: name ?? this.name,
      count: count ?? this.count,
      nullableValue: nullableValue,
    );
  }
}

class TestStateManager extends StateManager<TestState> {
  TestStateManager() : super(TestState());

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updateCount(int newCount) {
    state = state.copyWith(count: newCount);
  }

  void updateNullableValue(int? value) {
    state = state.copyWith(nullableValue: value);
  }
}
