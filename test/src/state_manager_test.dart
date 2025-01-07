import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/simple_state_manager.dart';

class TestStateManager extends StateManager<int> {
  TestStateManager() : super(0);

  void increment() {
    state = state + 1;
  }

  void setValue(int value) {
    state = value;
  }
}

void main() {
  group('StateManager', () {
    late TestStateManager manager;

    setUp(() {
      manager = TestStateManager();
    });

    tearDown(() {
      manager.dispose();
    });

    group('Should have correct initial state', () {
      test('when first created', () {
        expect(manager.state, equals(0));
      });
    });

    group('Should update state', () {
      test('when increment is called', () {
        manager.increment();
        expect(manager.state, equals(1));
      });

      test('when multiple increments are called', () {
        manager.increment();
        manager.increment();
        expect(manager.state, equals(2));
      });

      test('when value is set directly', () {
        manager.setValue(5);
        expect(manager.state, equals(5));
      });
    });

    group('Should maintain consistency', () {
      test('when checking notifier value against state', () {
        manager.increment();
        expect(manager.notifier.value, equals(manager.state));
      });
    });
  });
}
