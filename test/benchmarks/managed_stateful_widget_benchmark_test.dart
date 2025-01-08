import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  group('ManagedStatefulWidget Performance Benchmarks', () {
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
      'should initialize and dispose efficiently',
      (tester) async {
        int buildCount = 0;
        int initStateCount = 0;
        int disposeCount = 0;

        final initStopwatch = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestManagedStatefulWidget(
                onBuild: () => buildCount++,
                onInitState: () => initStateCount++,
                onDispose: () => disposeCount++,
              ),
            ),
          ),
        );
        final initTime = initStopwatch.elapsedMicroseconds;

        // Test cleanup and disposal
        await tester.pumpWidget(Container());

        debugPrint('''
ManagedStatefulWidget Lifecycle Performance:
- Initialization time: $initTime microseconds
- InitState calls: $initStateCount
- Dispose calls: $disposeCount
- Initial builds: $buildCount
''');
      },
    );

    testWidgets(
      'should handle state updates efficiently',
      (tester) async {
        int buildCount = 0;
        int stateManagerCreateCount = 0;

        final widget = MaterialApp(
          home: Scaffold(
            body: TestManagedStatefulWidget(
              onBuild: () => buildCount++,
              onStateManagerCreate: () => stateManagerCreateCount++,
            ),
          ),
        );

        await tester.pumpWidget(widget);
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          final state = tester.state<TestManagedStatefulWidgetState>(
              find.byType(TestManagedStatefulWidget));
          state.widget.stateManager
              .updateCount(state.widget.stateManager.state.count + 1);
          await tester.pump();
        });

        debugPrint('''
ManagedStatefulWidget Update Performance:
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds per update
- Builds per update: ${buildCount / iterations}
''');
      },
    );

    testWidgets(
      'should preserve state efficiently during rebuilds',
      (tester) async {
        int buildCount = 0;
        int stateManagerCreateCount = 0;
        int initStateCount = 0;
        int disposeCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestManagedStatefulWidget(
                onBuild: () => buildCount++,
                onStateManagerCreate: () => stateManagerCreateCount++,
                onInitState: () => initStateCount++,
                onDispose: () => disposeCount++,
              ),
            ),
          ),
        );
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          // Force parent rebuild while keeping state
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TestManagedStatefulWidget(
                  key: UniqueKey(),
                  onBuild: () => buildCount++,
                  onStateManagerCreate: () => stateManagerCreateCount++,
                  onInitState: () => initStateCount++,
                  onDispose: () => disposeCount++,
                ),
              ),
            ),
          );
        });

        debugPrint('''
ManagedStatefulWidget State Preservation:
- Average rebuild time: ${avgMicros.toStringAsFixed(2)} microseconds
- Total builds: ${buildCount / iterations}
- State manager recreations: $stateManagerCreateCount
- Additional initState calls: $initStateCount
- Additional dispose calls: $disposeCount
''');
      },
    );

    testWidgets(
      'should handle concurrent state updates efficiently',
      (tester) async {
        int buildCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TestManagedStatefulWidget(
                onBuild: () => buildCount++,
              ),
            ),
          ),
        );
        buildCount = 0;

        final avgMicros = await measureExecutionTime(() async {
          final state = tester.state<TestManagedStatefulWidgetState>(
              find.byType(TestManagedStatefulWidget));

          // Simulate concurrent updates
          state.widget.stateManager
              .updateCount(state.widget.stateManager.state.count + 1);
          state.widget.stateManager
              .updateCount(state.widget.stateManager.state.count + 2);
          state.widget.stateManager
              .updateCount(state.widget.stateManager.state.count + 3);

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 16)); // One frame
        });

        debugPrint('''
ManagedStatefulWidget Concurrent Updates:
- Average execution time: ${avgMicros.toStringAsFixed(2)} microseconds
- Builds per concurrent update: ${buildCount / iterations}
''');
      },
    );
  });
}

class TestManagedStatefulWidget extends StatefulWidget {
  final VoidCallback onBuild;
  final VoidCallback? onInitState;
  final VoidCallback? onDispose;
  final VoidCallback? onStateManagerCreate;
  final TestStateManager stateManager;

  TestManagedStatefulWidget({
    super.key,
    required this.onBuild,
    this.onInitState,
    this.onDispose,
    this.onStateManagerCreate,
  }) : stateManager = TestStateManager() {
    onStateManagerCreate?.call();
  }

  @override
  TestManagedStatefulWidgetState createState() =>
      TestManagedStatefulWidgetState();
}

class TestManagedStatefulWidgetState extends State<TestManagedStatefulWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInitState?.call();
  }

  @override
  void dispose() {
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild();
    return Text('${widget.stateManager.state.count}');
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
