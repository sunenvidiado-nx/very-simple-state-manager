import 'package:flutter/foundation.dart';

/// {@template state_manager}
/// Base class for state managers.
///
/// Usage:
/// ```dart
/// class CounterManager extends StateManager<int> {
///   CounterManager() : super(0);
///
///   void increment() {
///     setState((state) => state + 1);
///   }
/// }
/// ```
/// {@endtemplate}
abstract class StateManager<T> {
  /// The state notifier that will be used to manage the state.
  final ValueNotifier<T> _notifier;

  /// Maps original listeners to their wrapped versions
  final Map<void Function(T), VoidCallback> _wrappedListeners = {};

  // {@macro state_manager}
  @protected
  StateManager(T initialState) : _notifier = ValueNotifier(initialState);

  /// Returns the current state of the state manager.
  T get state => _notifier.value;

  /// Sets the state of the state manager.
  set state(T newState) => _notifier.value = newState;

  /// Adds a listener that will be called whenever the state changes.
  ///
  /// The listener will be called with the new state value.
  void addListener(void Function(T newState) listener) {
    if (_wrappedListeners.containsKey(listener)) {
      return;
    }
    void wrappedListener() {
      listener(state);
    }

    _wrappedListeners[listener] = wrappedListener;
    _notifier.addListener(wrappedListener);
  }

  /// Removes a previously added listener.
  ///
  /// If the given listener is not registered, this operation is a no-op.
  void removeListener(void Function(T newState) listener) {
    final wrappedListener = _wrappedListeners.remove(listener);
    if (wrappedListener != null) {
      _notifier.removeListener(wrappedListener);
    }
  }

  /// Releases allocated resources and cleans up the state manager.
  ///
  /// Must be called when the state manager is no longer needed to prevent memory leaks.
  /// Typically called from the [dispose] method of the parent widget or when
  /// cleaning up a service locator/dependency injection container.
  @mustCallSuper
  void dispose() {
    _wrappedListeners.clear();
    _notifier.dispose();
  }
}

extension StateManagerExtension<T> on StateManager<T> {
  ValueNotifier<T> get valueListenable => _notifier;
}
