import 'package:flutter/material.dart';

import 'state_builder.dart';
import 'state_manager.dart';

/// {@template managed_widget}
/// An abstract widget that manages its own state through a [StateManager].
/// The state manager is created lazily and cached for subsequent builds.
///
/// Usage:
/// ```dart
/// class CounterWidget extends ManagedWidget<CounterManager> {
///   const CounterWidget({super.key});
///
///   @override
///   CounterManager createStateManager() => CounterManager();
///
///   @override
///   Widget build(BuildContext context, CounterManager manager, dynamic state) {
///     return Text('Counter: $state');
///   }
/// }
/// ```
/// {@endtemplate}
abstract class ManagedWidget<T extends StateManager> extends StatelessWidget {
  /// {@macro managed_widget}
  const ManagedWidget({
    super.key,
    this.autoDispose = true,
  });

  /// Whether to automatically dispose the state manager when the widget is removed.
  final bool autoDispose;

  /// Cache for the state manager instance
  static final Map<Type, StateManager> _cache = {};

  /// Creates a new instance of the state manager.
  /// This method should be implemented by subclasses.
  T createStateManager();

  /// Gets or creates the state manager instance.
  T _getOrCreateStateManager() {
    if (!_cache.containsKey(T)) {
      _cache[T] = createStateManager();
    }
    return _cache[T]! as T;
  }

  /// Builds the widget with the current state.
  Widget build(BuildContext context, T manager, dynamic state);

  @override
  Widget build(BuildContext context) {
    final manager = _getOrCreateStateManager();

    if (autoDispose) {
      // Add dispose callback when the widget is removed from the tree
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          _cache.remove(T);
          manager.dispose();
        }
      });
    }

    return StateBuilder(
      stateManager: manager,
      builder: (context, state) => build(context, manager, state),
    );
  }
}
