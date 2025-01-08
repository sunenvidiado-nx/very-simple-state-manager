import 'package:flutter/material.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';
import 'counter_manager.dart';

void main() {
  runApp(const StateBuilderApp());
}

class StateBuilderApp extends StatelessWidget {
  const StateBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StateBuilderExample(),
    );
  }
}

class StateBuilderExample extends StatefulWidget {
  const StateBuilderExample({super.key});

  @override
  State<StateBuilderExample> createState() => _StateBuilderExampleState();
}

class _StateBuilderExampleState extends State<StateBuilderExample> {
  final _counter = CounterManager();

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StateBuilder'),
      ),
      body: Center(
        child: StateBuilder(
          stateManager: _counter,
          builder: (context, state) => Column(
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
                    onPressed: _counter.decrement,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 20),
                  FloatingActionButton(
                    onPressed: _counter.increment,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
