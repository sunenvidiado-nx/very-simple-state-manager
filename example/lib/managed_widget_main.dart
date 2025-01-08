import 'package:flutter/material.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'counter_manager.dart';

void main() {
  runApp(const ManagedWidgetApp());
}

class ManagedWidgetApp extends StatelessWidget {
  const ManagedWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ManagedWidgetExample(),
    );
  }
}

class ManagedWidgetExample extends ManagedWidget<CounterManager, int> {
  ManagedWidgetExample({super.key});

  late final _counterManager = CounterManager();

  @override
  CounterManager createStateManager() => _counterManager;

  @override
  Widget build(BuildContext context, int state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManagedWidget'),
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
                  onPressed: _counterManager.decrement,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _counterManager.increment,
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
