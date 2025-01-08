import 'package:flutter/material.dart';

import 'state_builder.dart';
import 'state_manager.dart';

/// {@template managed_widget}
/// A widget that automatically manages its state through a [StateManager].
/// Creates and disposes its state manager based on the widget's lifecycle.
///
/// Features:
/// - Auto-rebuilds on state changes
/// - Handles manager lifecycle
/// - Configurable auto-disposal (via [autoDispose] flag)
///
/// Example:
/// ```dart
/// class CounterWidget extends ManagedWidget {
///   const CounterWidget({super.key});
///
///   @override
///   CounterManager createStateManager() => CounterManager();
///
///   @override
///   Widget build(context, state) => Text('Count: $state');
/// }
/// ```
/// {@endtemplate}
abstract class ManagedWidget<M extends StateManager<S>, S>
    extends StatefulWidget {
  /// {@macro managed_widget}
  const ManagedWidget({
    super.key,
    this.autoDispose = true,
  });

  /// Whether to automatically dispose the state manager when the widget is removed.
  final bool autoDispose;

  /// Creates a new instance of the state manager.
  /// This method should be implemented by subclasses.
  M createStateManager();

  /// Builds the widget with the current state.
  Widget build(BuildContext context, S state);

  @override
  State<ManagedWidget<M, S>> createState() => _ManagedWidgetState<M, S>();
}

class _ManagedWidgetState<M extends StateManager<S>, S>
    extends State<ManagedWidget<M, S>> {
  late final M _manager;

  @override
  void initState() {
    super.initState();
    _manager = widget.createStateManager();
  }

  @override
  void dispose() {
    if (widget.autoDispose) _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateBuilder<S>(
      stateManager: _manager,
      builder: (context, state) => widget.build(context, state),
    );
  }
}
