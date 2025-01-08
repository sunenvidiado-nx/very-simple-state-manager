import 'package:flutter/material.dart';
import 'package:very_simple_state_manager/very_simple_state_manager.dart';

void main() {
  runApp(const SelectedStateBuilderApp());
}

class SelectedStateBuilderApp extends StatelessWidget {
  const SelectedStateBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SelectedStateBuilderExample(),
    );
  }
}

class UserState {
  final String name;
  final int age;
  final String email;

  UserState({
    required this.name,
    required this.age,
    required this.email,
  });

  UserState copyWith({
    String? name,
    int? age,
    String? email,
  }) {
    return UserState(
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
    );
  }
}

class UserManager extends StateManager<UserState> {
  UserManager()
      : super(UserState(
          name: 'John Doe',
          age: 25,
          email: 'john@example.com',
        ));

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }

  void incrementAge() {
    state = state.copyWith(age: state.age + 1);
  }

  void updateEmail(String newEmail) {
    state = state.copyWith(email: newEmail);
  }
}

class SelectedStateBuilderExample extends StatefulWidget {
  const SelectedStateBuilderExample({super.key});

  @override
  State<SelectedStateBuilderExample> createState() =>
      _SelectedStateBuilderExampleState();
}

class _SelectedStateBuilderExampleState
    extends State<SelectedStateBuilderExample> {
  final _userManager = UserManager();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _userManager.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelectedStateBuilder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This example demonstrates how SelectedStateBuilder only rebuilds'
              ' when the selected part of the state changes.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Name section with rebuild counter
            _buildSection(
              title: 'Name',
              content: _RebuildCounter(
                child: SelectedStateBuilder<UserManager, UserState, String>(
                  stateManager: _userManager,
                  selector: (state) => state.name,
                  builder: (context, name) => Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              textField: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter new name',
                ),
                onSubmitted: _userManager.updateName,
              ),
            ),
            const SizedBox(height: 16),
            // Age section with rebuild counter
            _buildSection(
              title: 'Age',
              content: _RebuildCounter(
                child: SelectedStateBuilder<UserManager, UserState, int>(
                  stateManager: _userManager,
                  selector: (state) => state.age,
                  builder: (context, age) => Text(
                    '$age years old',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              button: ElevatedButton(
                onPressed: _userManager.incrementAge,
                child: const Text('Increment Age'),
              ),
            ),
            const SizedBox(height: 16),
            // Email section with rebuild counter
            _buildSection(
              title: 'Email',
              content: _RebuildCounter(
                child: SelectedStateBuilder<UserManager, UserState, String>(
                  stateManager: _userManager,
                  selector: (state) => state.email,
                  builder: (context, email) => Text(
                    email,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              textField: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Enter new email',
                ),
                onSubmitted: _userManager.updateEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    TextField? textField,
    Widget? button,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        content,
        if (textField != null) ...[
          const SizedBox(height: 8),
          textField,
        ],
        if (button != null) ...[
          const SizedBox(height: 8),
          button,
        ],
      ],
    );
  }
}

class _RebuildCounter extends StatefulWidget {
  const _RebuildCounter({required this.child});

  final Widget child;

  @override
  State<_RebuildCounter> createState() => _RebuildCounterState();
}

class _RebuildCounterState extends State<_RebuildCounter> {
  int _rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.child,
        Text(
          'Rebuilds: ${_rebuilds++}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
