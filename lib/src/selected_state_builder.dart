import 'package:flutter/material.dart';

import 'state_manager.dart';

/// {@template selected_state_builder}
/// A widget that builds a widget based on a selected part of the state from a [StateManager].
/// This widget will only rebuild when the selected value changes, not when the entire state changes.
///
/// The [selector] function is used to select a specific part of the state. The widget
/// will only rebuild when the selected value changes according to the == operator.
///
/// Usage:
/// ```dart
/// class UserManager extends StateManager<User> {
///   UserManager() : super(User());
/// }
///
/// class NameWidget extends StatelessWidget {
///   const NameWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return SelectedStateBuilder<UserManager, User, String>(
///       stateManager: UserManager(),
///       selector: (state) => state.name,
///       builder: (context, name) => Text('Name: $name'),
///     );
///   }
/// }
/// ```
///
/// Note: For complex objects, consider implementing [==] and [hashCode] or using
/// a custom equality comparison to ensure proper rebuild behavior.
/// {@endtemplate}
class SelectedStateBuilder<M extends StateManager<T>, T, S>
    extends StatefulWidget {
  /// {@macro selected_state_builder}
  const SelectedStateBuilder({
    super.key,
    required this.stateManager,
    required this.selector,
    required this.builder,
    this.equals,
  });

  /// The [StateManager] to bind to.
  final M stateManager;

  /// Function that selects a part of the state.
  ///
  /// This function should be pure and not have any side effects.
  /// It will be called whenever the state changes to determine if a rebuild is needed.
  final S Function(T state) selector;

  /// The function that builds the widget based on the selected state.
  final Widget Function(BuildContext context, S selectedState) builder;

  /// Optional custom equality function.
  ///
  /// If provided, this function will be used instead of the == operator
  /// to determine if the selected state has changed.
  final bool Function(S previous, S next)? equals;

  @override
  State<SelectedStateBuilder<M, T, S>> createState() =>
      _SelectedStateBuilderState<M, T, S>();
}

class _SelectedStateBuilderState<M extends StateManager<T>, T, S>
    extends State<SelectedStateBuilder<M, T, S>> {
  late S _selectedState;
  late M _stateManager;

  bool get _shouldRebuild {
    try {
      final newSelectedState = widget.selector(_stateManager.state);
      if (widget.equals != null) {
        return !widget.equals!(_selectedState, newSelectedState);
      }
      return _selectedState != newSelectedState;
    } catch (e) {
      // If selector throws, we should rebuild to show potential error state
      return true;
    }
  }

  void _subscribe() {
    _stateManager = widget.stateManager;
    try {
      _selectedState = widget.selector(_stateManager.state);
    } catch (e) {
      // Handle selector errors gracefully
      debugPrint('Error in SelectedStateBuilder selector: $e');
      rethrow;
    }
    _stateManager.addListener(_onStateChanged);
  }

  void _unsubscribe() {
    _stateManager.removeListener(_onStateChanged);
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(SelectedStateBuilder<M, T, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stateManager != widget.stateManager) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _onStateChanged(T state) {
    if (_shouldRebuild) {
      setState(() {
        try {
          _selectedState = widget.selector(state);
        } catch (e) {
          // Handle selector errors gracefully
          debugPrint('Error in SelectedStateBuilder selector: $e');
          rethrow;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return widget.builder(context, _selectedState);
    } catch (e) {
      return ErrorWidget('Error building SelectedStateBuilder: $e');
    }
  }
}
