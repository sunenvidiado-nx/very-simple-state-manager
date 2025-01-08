# Very Simple State Manager

[![Tests](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml/badge.svg)](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml)
[![codecov](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager/branch/main/graph/badge.svg)](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager)
[![Pub Version](https://img.shields.io/pub/v/very_simple_state_manager)](https://pub.dev/packages/very_simple_state_manager)


Yeah, I know - another state management solution. But this one? It's refreshingly simple! 🌟

A lightweight state management solution built on Flutter's core concepts. Taking inspiration from BLoC's structured approach and ChangeNotifier's simplicity, it provides a clean, effective API without unnecessary complexity.

## ✨ Features

- **Simplicity**: Designed for quick adoption and ease of use
- **Reactive Updates**: Automatic UI synchronization with state changes
- **Clean Architecture**: Clear separation between state logic and UI
- **Performance**: Leverages Flutter's efficient `ValueNotifier` system
- **Lightweight**: Zero external dependencies

## 🔍 Under the Hood

Why reinvent the wheel when Flutter already provides great building blocks? We take Flutter's built-in state management concepts and wrap them in a developer-friendly API:

- `ValueNotifier`: Think of it as a smart box that tells everyone when its contents change
- `ValueListenableBuilder`: The messenger that tells your UI when to update

Instead of using these directly, we wrap them in two intuitive classes:
- `StateManager`: A clean wrapper around `ValueNotifier` that makes state updates a breeze
- `StateBuilder`: A smarter version of `ValueListenableBuilder` that makes UI updates dead simple

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

There are three ways to use state managers in your UI:

#### Option 1: StateBuilder

The most basic way to connect state to UI:

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
    _counter.dispose(); // Don't forget to dispose state managers 🧹
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

#### Option 2: ManagedWidget

A simpler way that handles state manager lifecycle automatically:

```dart
class CounterWidget extends ManagedWidget<CounterManager, int> {
  @override
  CounterManager createStateManager() => CounterManager();

  @override
  Widget build(BuildContext context, int state) {
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

#### Option 3: ManagedStatefulWidget

When you need both state management and StatefulWidget capabilities:

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
        child: Text('Count: $state'), // Access state through getter
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleIncrement,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 3. Simple Yet Powerful 💪

Handle complex state management with clean, maintainable code:

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
}
```

## 💡 Best Practices

1. **Resource Management**: Always dispose state managers to prevent memory leaks
2. **Single Responsibility**: Each state manager should handle one logical unit of state
3. **Immutability**: Treat state as immutable to prevent unintended side effects
4. **Type Safety**: Leverage Dart's type system for better maintainability

## 🎯 Examples

Check out the `/example` directory for practical demonstrations and usage patterns.

## 🤝 Contributing

We welcome contributions! Feel free to submit issues and pull requests.

## 📄 License

Licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
