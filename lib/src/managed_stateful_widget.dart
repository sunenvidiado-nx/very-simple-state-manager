import 'package:flutter/material.dart';

import 'state_manager.dart';

/// {@template managed_stateful_widget}
/// A stateful widget that automatically manages its state through a [StateManager].
/// Creates and disposes its state manager based on the widget's lifecycle.
///
/// Features:
/// - Auto-rebuilds on state changes
/// - Handles manager lifecycle
/// - Configurable auto-disposal (via [autoDispose] flag)
/// - State accessible throughout the subclass
///
/// Example:
/// ```dart
/// class CounterWidget extends ManagedStatefulWidget<CounterManager, int> {
///   const CounterWidget({super.key, super.autoDispose = true});
///
///   @override
///   CounterManager createStateManager() => CounterManager();
///
///   @override
///   State<CounterWidget> createState() => _CounterWidgetState();
/// }
///
/// class _CounterWidgetState extends ManagedState<CounterManager, int, CounterWidget> {
///   void _handleIncrement() {
///     // Access state manager directly through stateManager property
///     stateManager.increment();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // Access current state through currentState property
///     return Column(
///       children: [
///         Text('Counter: ${currentState}'),
///         ElevatedButton(
///           onPressed: _handleIncrement,
///           child: Text('Increment'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
/// {@endtemplate}
abstract class ManagedStatefulWidget<M extends StateManager<S>, S>
    extends StatefulWidget {
  /// {@macro managed_stateful_widget}
  const ManagedStatefulWidget({
    super.key,
    this.autoDispose = true,
  });

  /// Whether to automatically dispose the state manager when the widget is removed.
  final bool autoDispose;

  /// Creates a new instance of the state manager.
  /// This method should be implemented by subclasses.
  M createStateManager();
}

/// Base state class for [ManagedStatefulWidget].
/// Provides access to the state manager and current state throughout the class.
abstract class ManagedState<M extends StateManager<S>, S,
    T extends ManagedStatefulWidget<M, S>> extends State<T> {
  late final M _manager;
  bool _isDisposed = false;

  @override
  void initState() {
    _manager = widget.createStateManager();
    super.initState();
    _manager.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _manager.removeListener(_handleStateChange);
    if (widget.autoDispose) _manager.dispose();
    super.dispose();
  }

  void _handleStateChange(S _) {
    if (!_isDisposed) setState(() {}); // Trigger a rebuild
  }

  /// The current state manager instance.
  M get stateManager => _manager;

  /// The current state value.
  S get state => _manager.state;
}
