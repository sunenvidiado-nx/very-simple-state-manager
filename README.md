# Very Simple State Manager

[![Tests](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml/badge.svg)](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml)
[![codecov](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager/branch/main/graph/badge.svg)](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager)
[![Pub Version](https://img.shields.io/pub/v/very_simple_state_manager)](https://pub.dev/packages/very_simple_state_manager)
[![License](https://img.shields.io/badge/license-BSD-blue.svg)](https://raw.githubusercontent.com/sunenvidiado-nx/very-simple-state-manager/main/LICENSE)


Yep, another Flutter state management solution - but hear me out, this one's refreshingly simple! ✨

## 🔍 How It Works

This state manager integrates Flutter's core components with BLoC's architecture, `ChangeNotifier`'s simplicity, and Riverpod's state-aware capabilities.

Features:

- Simple: Easy to grasp and implement (hence the name!)
- Reactive: UI updates automatically with state changes
- Clean: Keeps logic and UI separate for better code organization
- Dependency-Free: Zero external packages—powered by Flutter's `ValueNotifier` and `ValueListenableBuilder`

## 🚀 Getting Started

Add the package to your Flutter project:

```bash
flutter pub add very_simple_state_manager
```

## 📖 Usage

### 1. Create Your State Manager

Create a counter with just a few lines of code:

```dart
class CounterManager extends StateManager<int> {
  CounterManager() : super(0);

  void increment() {
    state = state + 1;
  }
}
```

### 2. Use It In Your UI

There are four ways to make your UI responsive to state changes:

#### Option 1: `StateBuilder`

The easiest way to react to state changes:

```dart
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late final CounterManager _counter;

  @override
  void initState() {
    super.initState();
    _counter = CounterManager();
  }

  @override
  void dispose() {
    _counter.dispose(); // Don't forget to dispose state managers 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StateBuilder(
        stateManager: _counter,
        builder: (context, count) => Center(
          child: Text('Count: $count'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _counter.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### Option 2: `ManagedWidget`

An alternative to `StatelessWidget` that automatically rebuilds on state changes:

```dart
class CounterWidget extends ManagedWidget<CounterManager, int> {
  @override
  CounterManager createStateManager() => CounterManager();

  @override
  Widget build(BuildContext context, int state) { // Access state here!
    return Scaffold(
      body: Center(
        child: Text('Count: $state'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: stateManager.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### Option 3: `ManagedStatefulWidget`

When you need `StatefulWidget` capabilities and auto-rebuilds on state changes:

```dart
class CounterWidget extends ManagedStatefulWidget<CounterManager, int> {
  const CounterWidget({super.key});

  @override
  CounterManager createStateManager() => CounterManager();

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends ManagedState<CounterManager, int, CounterWidget> {
  void _handleIncrement() {
    stateManager.increment(); // Access state manager directly!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Count: $state'), // Access state directly!
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleIncrement,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

#### Option 4: `SelectedStateBuilder`

When you only need to rebuild based on a selected part of the state:

```dart
class ComplexCounterManager extends StateManager<CounterState> {
  ComplexCounterManager() : super(CounterState(count: 0, lastUpdated: DateTime.now()));

  void increment() {
    state = CounterState(count: state.count + 1, lastUpdated: DateTime.now());
  }
}

class CounterWidget extends StatelessWidget {
  final ComplexCounterManager _counter = ComplexCounterManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Only rebuilds when count changes
          SelectedStateBuilder(
            stateManager: _counter,
            selector: (state) => state.count,
            builder: (context, count) => Text('Count: $count'),
          ),
          // Only rebuilds when lastUpdated changes
          SelectedStateBuilder(
            stateManager: _counter,
            selector: (state) => state.lastUpdated,
            builder: (context, lastUpdated) => Text('Last Updated: $lastUpdated'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _counter.increment,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 3. Simple Yet Powerful 💪

Handle complex state management with clean, maintainable code!

```dart
class UserManager extends StateManager<UserState> {
  UserManager(this._repository) : super(InitialUserState());

  final UserRepository _repository;

  Future<void> loadUser(String id) async {
    state = LoadingUserState();

    try {
      final user = await _repository.getUserById(id);
      state = LoadedUserState(user);
    } on Exception catch (e) {
      state = ErrorUserState(e);
    }
  }

  void updateName(String newName) {
    state = LoadedUserState(state.user.copyWith(name: newName));
  }

  // Other complex state management logic ...
}
```

## 💡 Best Practices

1. **Resource Management**: Always dispose state managers to prevent memory leaks
2. **Single Responsibility**: Each state manager should handle one logical unit of state
3. **Immutability**: Treat state as immutable to prevent unintended side effects
4. **Type Safety**: Use generic types with your state managers for better compile-time checks
5. **Widget Choice**: Pick the right widget for your needs:
   - Use `StateBuilder` for simple state-to-UI bindings
   - Use `ManagedWidget` for stateless widgets that need state
   - Use `ManagedStatefulWidget` when you need both state and lifecycle methods
   - Use `SelectedStateBuilder` when you only need to rebuild based on a selected part of the state
6. **Error Handling**: Always handle error states in your state managers (like in the `UserManager` example)
7. **Code Organization**: Keep your state managers and widgets organized in separate files or folders
8. **Testing**: Write tests for your state managers and widgets to ensure they work as expected

## 🎯 Examples

Check out the `/example` directory for practical demonstrations and usage patterns.

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

## 📄 License

Licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
