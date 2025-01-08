import 'package:very_simple_state_manager/very_simple_state_manager.dart';

class CounterManager extends StateManager<int> {
  CounterManager() : super(0);

  void increment() => state = state + 1;
  void decrement() => state = state - 1;
}
