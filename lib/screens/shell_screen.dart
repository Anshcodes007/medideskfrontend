import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';
import 'appointments_screen.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'prescriptions_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Patients', 'Appointments', 'Prescriptions'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MediDesk'),
            if (user != null)
              Text(
                user.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          PatientsScreen(),
          AppointmentsScreen(),
          PrescriptionsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: _titles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: _titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.event_outlined),
            selectedIcon: const Icon(Icons.event),
            label: _titles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication),
            label: _titles[3],
          ),
        ],
      ),
    );
  }
}
