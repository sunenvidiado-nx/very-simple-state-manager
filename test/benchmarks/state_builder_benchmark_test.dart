import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  group('StateBuilder Performance Benchmarks', () {
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
      'should rebuild efficiently on simple state changes',
      (tester) async {
        int buildCount = 0;

        final widget = MaterialApp(
          home: StateBuilder(
            stateManager: stateManager,
            builder: (context, state) {
              buildCount++;
              return Text('${state.count}');
            },
          ),
        );

        await tester.pumpWidget(widget);
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateCount(stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
StateBuilder Performance (Simple Update):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Builds per update: ${buildCount / iterations}
''');
      },
    );

    testWidgets(
      'should handle rapid consecutive updates efficiently',
      (tester) async {
        int buildCount = 0;

        final widget = MaterialApp(
          home: StateBuilder(
            stateManager: stateManager,
            builder: (context, state) {
              buildCount++;
              return Text('${state.count}');
            },
          ),
        );

        await tester.pumpWidget(widget);
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          // Simulate rapid updates
          stateManager.updateCount(stateManager.state.count + 1);
          stateManager.updateCount(stateManager.state.count + 1);
          stateManager.updateCount(stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
StateBuilder Performance (Rapid Updates):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Builds per update: ${buildCount / iterations}
''');
      },
    );

    testWidgets(
      'should scale linearly with multiple builders',
      (tester) async {
        int buildCount = 0;
        const numBuilders = 10;

        final widgets = List.generate(
          numBuilders,
          (index) => StateBuilder(
            stateManager: stateManager,
            builder: (context, state) {
              buildCount++;
              return Text('${state.count}');
            },
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Column(children: widgets),
          ),
        );
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateCount(stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
StateBuilder Performance (Multiple Builders):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Total builds per update: ${buildCount / iterations}
- Builds per widget: ${(buildCount / iterations) / numBuilders}
''');
      },
    );

    testWidgets(
      'should maintain performance with complex state objects',
      (tester) async {
        int buildCount = 0;

        final widget = MaterialApp(
          home: StateBuilder(
            stateManager: stateManager,
            builder: (context, state) {
              buildCount++;
              return Column(
                children: [
                  Text('Count: ${state.count}'),
                  Text('Name: ${state.name}'),
                  Text('Complex: ${state.complexObject.value}'),
                  if (state.nullableValue != null)
                    Text('Nullable: ${state.nullableValue}'),
                ],
              );
            },
          ),
        );

        await tester.pumpWidget(widget);
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          stateManager.updateComplexObject(ComplexObject(
            id: stateManager.state.complexObject.id,
            value: stateManager.state.complexObject.value + 1,
          ));
          await tester.pump();
        });

        debugPrint('''
StateBuilder Performance (Complex State):
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Builds per update: ${buildCount / iterations}
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
