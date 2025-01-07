# Very Simple State Manager

[![Tests](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml/badge.svg)](https://github.com/sunenvidiado-nx/very-simple-state-manager/actions/workflows/test.yaml)
[![codecov](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager/branch/main/graph/badge.svg)](https://codecov.io/gh/sunenvidiado-nx/very-simple-state-manager)

Tired of complex state management solutions? Say hello to a very simple state manager! 🙌

This lightweight package makes Flutter state management a breeze, built on top of Flutter's own `ValueNotifier` and `ValueListenableBuilder`. No magic, no complexity - just simple, effective state management that gets the job done.

## ✨ Features

- 🎯 **Keep It Simple**: Super easy to learn and use - you'll be up and running in minutes!
- 🔄 **Auto-Magic UI Updates**: Your UI stays in sync with your state - no extra code needed
- 🎨 **Clean & Tidy**: Keep your state logic separate from your UI - your future self will thank you
- 🚀 **Fast & Efficient**: Built on Flutter's `ValueNotifier` for speedy updates
- 📦 **Zero Bloat**: No external dependencies - just pure Flutter goodness

## 🔍 Under the Hood

We've built Simple State Manager on two awesome Flutter concepts:
- `ValueNotifier`: Think of it as a smart box that tells everyone when its contents change
- `ValueListenableBuilder`: The messenger that tells your UI when to update

We've wrapped these up in a friendly API that makes state management feel like a walk in the park! 

## 🚀 Getting Started

Add the package to your Flutter project:

```bash
flutter pub add very_simple_state_manager
```

## 📖 Usage

### 1. Create Your State Manager

Here's how easy it is to create a counter:

```dart
class CounterManager extends StateManager<int> {
  CounterManager() : super(0); // Start at zero!

  void increment() {
    state = state + 1; // Simple as that!
  }
}
```

### 2. Use It In Your UI

Wrap your widgets with `StateBuilder` and watch the magic happen:

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
    _counter.dispose(); // Clean up after yourself! 🧹
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StateBuilder(
          stateManager: _counter,
          builder: (context, count) => Text('Count: $count'),
        ),
        ElevatedButton(
          onPressed: _counter.increment,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

### 3. Level Up! 🎮

Want to manage something more complex? We've got you covered:

```dart
class UserManager extends StateManager<User> {
  UserManager() : super(User.empty());

  Future<void> loadUser(String id) async {
    // Fetch that user data!
    final user = await api.getUser(id);
    state = user;
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }
}
```

## 💡 Pro Tips

1. **Clean Up**: Always dispose your state managers - keep your app running smooth! 
2. **Stay Focused**: One state manager, one job - keep it simple!
3. **Keep It Immutable**: Treat your state like a precious gem - don't modify it directly
4. **Type It Out**: Use specific types instead of dynamic - your IDE will love you for it

## 🎮 Try It Out

Want to see it in action? Check out the `/example` directory for a cool counter app demo!

## 🤝 Contributing

Found a bug? Have a cool idea? We'd love to hear from you! Feel free to open an issue or send a PR.

## 📄 License

This project is licensed under the BSD 3-Clause License - check out the [LICENSE](LICENSE) file for the legal stuff.
