import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'state/auth_controller.dart';

class MediDeskApp extends StatelessWidget {
  const MediDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediDesk',
      debugShowCheckedModeBanner: false,
      theme: MediDeskTheme.light(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!auth.isLoggedIn) return const LoginScreen();
    return const ShellScreen();
  }
}
