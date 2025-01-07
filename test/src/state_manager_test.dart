import 'package:flutter_test/flutter_test.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

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

    group('Listener functionality', () {
      test('should notify listeners when state changes', () {
        int callCount = 0;
        int? lastValue;
        
        manager.addListener((value) {
          callCount++;
          lastValue = value;
        });

        manager.increment();
        expect(callCount, equals(1));
        expect(lastValue, equals(1));

        manager.setValue(5);
        expect(callCount, equals(2));
        expect(lastValue, equals(5));
      });

      test('should not notify removed listeners', () {
        int callCount = 0;
        void listener(int value) => callCount++;
        
        manager.addListener(listener);
        manager.increment();
        expect(callCount, equals(1));

        manager.removeListener(listener);
        manager.increment();
        expect(callCount, equals(1), reason: 'Listener should not be called after removal');
      });

      test('should handle multiple listeners', () {
        int callCount1 = 0;
        int callCount2 = 0;
        
        manager.addListener((_) => callCount1++);
        manager.addListener((_) => callCount2++);

        manager.increment();
        expect(callCount1, equals(1));
        expect(callCount2, equals(1));
      });
    });
  });
}
