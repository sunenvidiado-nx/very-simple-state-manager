import 'package:flutter/foundation.dart';

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
abstract class StateManager<T> {
  /// The state notifier that will be used to manage the state.
  final ValueNotifier<T> notifier;

  /// Maps original listeners to their wrapped versions
  final Map<void Function(T), VoidCallback> _wrappedListeners = {};

  /// Constructor that initializes the notifier with an initial state.
  @protected
  StateManager(T initialState) : notifier = ValueNotifier(initialState);

  /// Returns the current state of the state manager.
  T get state => notifier.value;

  /// Sets the state of the state manager.
  set state(T newState) => notifier.value = newState;

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
    notifier.addListener(wrappedListener);
  }

  /// Removes a previously added listener.
  ///
  /// If the given listener is not registered, this operation is a no-op.
  void removeListener(void Function(T newState) listener) {
    final wrappedListener = _wrappedListeners.remove(listener);
    if (wrappedListener != null) {
      notifier.removeListener(wrappedListener);
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
    notifier.dispose();
  }
}
