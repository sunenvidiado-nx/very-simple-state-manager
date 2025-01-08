import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  group('ManagedWidget Performance Benchmarks', () {
    const int iterations = 1000;
    const int warmupIterations = 100;

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
      'should initialize state manager efficiently',
      (tester) async {
        int buildCount = 0;
        int stateManagerCreateCount = 0;

        final initStopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: TestManagedWidget(
              onBuild: () => buildCount++,
              onStateManagerCreate: () => stateManagerCreateCount++,
            ),
          ),
        );
        final initTime = initStopwatch.elapsedMicroseconds;

        debugPrint('''
ManagedWidget Initialization Performance:
- Initialization time: $initTime microseconds
- State manager creations: $stateManagerCreateCount
- Initial builds: $buildCount
''');
      },
    );

    testWidgets(
      'should handle state updates efficiently',
      (tester) async {
        int buildCount = 0;

        final widget = MaterialApp(
          home: TestManagedWidget(
            onBuild: () => buildCount++,
          ),
        );

        await tester.pumpWidget(widget);
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          final element = tester.element(find.byType(TestManagedWidget));
          final managedWidget = element.widget as TestManagedWidget;
          managedWidget._stateManager.updateCount(
              managedWidget._stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
ManagedWidget Update Performance:
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Builds per update: ${buildCount / iterations}
''');
      },
    );

    testWidgets(
      'should maintain performance during parent rebuilds',
      (tester) async {
        int buildCount = 0;
        int stateManagerCreateCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: TestManagedWidget(
              onBuild: () => buildCount++,
              onStateManagerCreate: () => stateManagerCreateCount++,
            ),
          ),
        );
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          await tester.pumpWidget(
            MaterialApp(
              home: TestManagedWidget(
                key: UniqueKey(),
                onBuild: () => buildCount++,
                onStateManagerCreate: () => stateManagerCreateCount++,
              ),
            ),
          );
        });

        debugPrint('''
ManagedWidget Parent Rebuild Performance:
- Average rebuild time: ${avgMicros.toStringAsFixed(2)} microseconds
- Total builds: ${buildCount / iterations}
- State manager recreations: $stateManagerCreateCount
''');
      },
    );

    testWidgets(
      'should scale linearly with nested managed widgets',
      (tester) async {
        int buildCount = 0;
        int stateManagerCreateCount = 0;
        const int depth = 5;

        Widget buildNestedWidgets(int currentDepth) {
          if (currentDepth == 0) {
            return const SizedBox();
          }
          return TestManagedWidget(
            onBuild: () => buildCount++,
            onStateManagerCreate: () => stateManagerCreateCount++,
            child: buildNestedWidgets(currentDepth - 1),
          );
        }

        await tester.pumpWidget(
          MaterialApp(
            home: buildNestedWidgets(depth),
          ),
        );
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          final elements = tester.elementList(find.byType(TestManagedWidget));
          for (final element in elements) {
            final widget = element.widget as TestManagedWidget;
            widget._stateManager.updateCount(widget._stateManager.state.count + 1);
          }
          await tester.pump();
        });

        debugPrint('''
ManagedWidget Nested Performance:
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Total builds per update: ${buildCount / iterations}
- Builds per widget: ${(buildCount / iterations) / depth}
''');
      },
    );
  });
}

class TestManagedWidget extends ManagedWidget<TestStateManager, TestState> {
  final VoidCallback onBuild;
  final VoidCallback? onStateManagerCreate;
  final Widget? child;
  final TestStateManager _stateManager;

  TestManagedWidget({
    super.key,
    required this.onBuild,
    this.onStateManagerCreate,
    this.child,
  }) : _stateManager = TestStateManager() {
    onStateManagerCreate?.call();
  }

  @override
  TestStateManager createStateManager() => _stateManager;

  @override
  Widget build(BuildContext context, TestState state) {
    onBuild();
    return child ?? Text('${state.count}');
  }
}

class TestStateManager extends StateManager<TestState> {
  TestStateManager() : super(TestState(count: 0));

  void updateCount(int newCount) {
    state = TestState(count: newCount);
  }
}

class TestState {
  final int count;

  TestState({required this.count});
}
