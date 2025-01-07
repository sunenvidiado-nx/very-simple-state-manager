import 'package:flutter/material.dart';

import '../very_simple_state_manager.dart';

/// {@template state_builder}
///
/// A widget that builds a widget based on the state of a [StateManager].
///
/// Usage:
/// ```dart
/// class CounterManager extends StateManager<int> {
///   CounterManager() : super(0);
///
///   void increment() {
///     state = state + 1;
///   }
/// }
///
/// class CounterWidget extends StatelessWidget {
///   const CounterWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return StateBuilder<CounterManager>(
///       stateManager: CounterManager(),
///       builder: (context, state) => Text('Counter: ${state}'),
///     );
///   }
/// }
/// ```
///
/// {@endtemplate}
class StateBuilder<T> extends StatelessWidget {
  /// {@macro state_builder}
  const StateBuilder({
    super.key,
    required this.stateManager,
    required this.builder,
  });

  /// The [StateManager] to bind to.
  final StateManager<T> stateManager;

  /// The function that builds the widget based on the state.
  final Function(BuildContext context, T state) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: stateManager.notifier,
      builder: (context, value, _) => builder(context, value),
    );
  }
}
