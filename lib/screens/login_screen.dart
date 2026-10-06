import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isRegister = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    if (_isRegister) {
      await auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      await auth.login(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'MediDesk',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Secure clinic access for doctors'),
                    const SizedBox(height: 32),
                    if (auth.error != null) ErrorBanner(message: auth.error!),
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Doctor name'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final email = v.trim();
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                          return 'Enter a valid email (e.g. name@gmail.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Password is required' : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: auth.busy ? null : _submit,
                      child: Text(
                        auth.busy
                            ? 'Please wait…'
                            : _isRegister
                                ? 'Register and login'
                                : 'Login',
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister
                            ? 'Have an account? Login'
                            : 'New doctor? Register',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
