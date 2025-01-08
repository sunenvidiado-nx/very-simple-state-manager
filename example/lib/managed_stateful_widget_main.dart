import 'package:flutter/material.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'counter_manager.dart';

void main() {
  runApp(const ManagedStatefulWidgetApp());
}

class ManagedStatefulWidgetApp extends StatelessWidget {
  const ManagedStatefulWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CounterStatefulWidget(),
    );
  }
}

class CounterStatefulWidget extends ManagedStatefulWidget<CounterManager, int> {
  const CounterStatefulWidget({super.key, super.autoDispose = true});

  @override
  CounterManager createStateManager() => CounterManager();

  @override
  State<CounterStatefulWidget> createState() => _CounterStatefulWidgetState();
}

class _CounterStatefulWidgetState
    extends ManagedState<CounterManager, int, CounterStatefulWidget> {
  void _handleIncrement() {
    stateManager.increment(); // Access state manager directly!
  }

  void _handleDecrement() {
    stateManager.decrement(); // Access state manager directly!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManagedStatefulWidget'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.toString(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: _handleDecrement,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _handleIncrement,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
