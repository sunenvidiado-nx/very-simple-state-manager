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
