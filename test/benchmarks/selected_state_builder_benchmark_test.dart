import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  group('SelectedStateBuilder Performance Benchmarks', () {
    late TestStateManager stateManager;
    const int iterations = 1000;
    const int warmupIterations = 100;

    setUp(() {
      stateManager = TestStateManager();
    });

    Future<double> measureExecutionTime(Future<void> Function() fn) async {
      // Warmup
      for (var i = 0; i < warmupIterations; i++) {
        await fn();
      }

      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < iterations; i++) {
        await fn();
      }
      stopwatch.stop();

      return stopwatch.elapsedMicroseconds / iterations;
    }

    testWidgets(
      'should have optimal performance with simple value comparison',
      (tester) async {
        int selectorCallCount = 0;

        final widget = MaterialApp(
          home: SelectedStateBuilder<TestStateManager, TestState, int>(
            stateManager: stateManager,
            selector: (state) {
              selectorCallCount++;
              return state.count;
            },
            builder: (context, count) => Text('$count'),
          ),
        );

        await tester.pumpWidget(widget);
        selectorCallCount = 0; // Reset after initial build

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateCount(stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
Performance Results (Simple Value):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Selector calls per update: ${selectorCallCount / iterations}
''');
      },
    );

    testWidgets(
      'should efficiently handle complex object comparisons',
      (tester) async {
        int selectorCallCount = 0;
        int equalsCallCount = 0;

        final widget = MaterialApp(
          home:
              SelectedStateBuilder<TestStateManager, TestState, ComplexObject>(
            stateManager: stateManager,
            selector: (state) {
              selectorCallCount++;
              return state.complexObject;
            },
            equals: (prev, next) {
              equalsCallCount++;
              return prev.id == next.id && prev.value == next.value;
            },
            builder: (context, obj) => Text('${obj.value}'),
          ),
        );

        await tester.pumpWidget(widget);
        selectorCallCount = 0;
        equalsCallCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateComplexObject(ComplexObject(
            id: stateManager.state.complexObject.id,
            value: stateManager.state.complexObject.value + 1,
          ));
          await tester.pump();
        });

        debugPrint('''
Performance Results (Complex Object):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Selector calls per update: ${selectorCallCount / iterations}
- Equals calls per update: ${equalsCallCount / iterations}
''');
      },
    );

    testWidgets(
      'should scale linearly with multiple selectors',
      (tester) async {
        int selectorCallCount = 0;
        const numSelectors = 10;

        final widgets = List.generate(
          numSelectors,
          (index) => SelectedStateBuilder<TestStateManager, TestState, int>(
            stateManager: stateManager,
            selector: (state) {
              selectorCallCount++;
              return state.count;
            },
            builder: (context, count) => Text('$count'),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Column(children: widgets),
          ),
        );
        selectorCallCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateCount(stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
Performance Results (Multiple Selectors):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Total selector calls per update: ${selectorCallCount / iterations}
- Selector calls per widget: ${(selectorCallCount / iterations) / numSelectors}
''');
      },
    );
  });
}

class TestStateManager extends StateManager<TestState> {
  TestStateManager()
      : super(TestState(
          count: 0,
          name: 'initial',
          nullableValue: null,
          complexObject: ComplexObject(id: 1, value: 1),
        ));

  void updateCount(int newCount) {
    state = state.copyWith(count: newCount);
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void updateNullableValue(int? value) {
    state = state.copyWith(nullableValue: () => value);
  }

  void updateComplexObject(ComplexObject newObject) {
    state = state.copyWith(complexObject: newObject);
  }
}

class TestState {
  final int count;
  final String name;
  final int? nullableValue;
  final ComplexObject complexObject;

  TestState({
    required this.count,
    required this.name,
    required this.nullableValue,
    required this.complexObject,
  });

  TestState copyWith({
    int? count,
    String? name,
    int? Function()? nullableValue,
    ComplexObject? complexObject,
  }) {
    return TestState(
      count: count ?? this.count,
      name: name ?? this.name,
      nullableValue:
          nullableValue != null ? nullableValue() : this.nullableValue,
      complexObject: complexObject ?? this.complexObject,
    );
  }
}

class ComplexObject {
  final int id;
  final int value;

  ComplexObject({required this.id, required this.value});
}
