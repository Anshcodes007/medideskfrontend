import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';
import '../widgets/common.dart';
import 'appointments_screen.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart';
import 'prescriptions_screen.dart';

class ShellNavigationScope extends InheritedWidget {
  const ShellNavigationScope({
    super.key,
    required this.currentIndex,
    required this.setTab,
    required super.child,
  });

  final int currentIndex;
  final void Function(int) setTab;

  static ShellNavigationScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellNavigationScope>();
  }

  @override
  bool updateShouldNotify(ShellNavigationScope oldWidget) {
    return currentIndex != oldWidget.currentIndex;
  }
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Patients', 'Appointments', 'Prescriptions'];

  void _setTab(int i) {
    if (_index != i) {
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;

    return ShellNavigationScope(
      currentIndex: _index,
      setTab: _setTab,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF2F6),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop) _buildSidebar(context, user),
              Expanded(
                child: Column(
                  children: [
                    if (!isDesktop) _buildMobileHeader(context, user),
                    Expanded(
                      child: IndexedStack(
                        index: _index,
                        children: const [
                          DashboardScreen(),
                          PatientsScreen(),
                          AppointmentsScreen(),
                          PrescriptionsScreen(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: isDesktop
            ? null
            : NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: _setTab,
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_outlined),
                    selectedIcon: const Icon(Icons.grid_view_rounded),
                    label: _titles[0],
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.people_outline),
                    selectedIcon: const Icon(Icons.people),
                    label: _titles[1],
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.calendar_today_outlined),
                    selectedIcon: const Icon(Icons.calendar_month),
                    label: _titles[2],
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.medication_outlined),
                    selectedIcon: const Icon(Icons.medication),
                    label: _titles[3],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const HourglassBrandLogo(title: 'MediDesk'),
              if (user != null) ...[
                const SizedBox(width: 8),
                Text(
                  '· ${user.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, dynamic user) {
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFEDF2F6),
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: HourglassBrandLogo(title: 'MediDesk'),
          ),
          const SizedBox(height: 28),
          // Nav items
          _SidebarItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            isSelected: _index == 0,
            onTap: () => _setTab(0),
          ),
          const SizedBox(height: 6),
          _SidebarItem(
            icon: Icons.people_outline_rounded,
            label: 'Patients',
            isSelected: _index == 1,
            onTap: () => _setTab(1),
          ),
          const SizedBox(height: 6),
          _SidebarItem(
            icon: Icons.calendar_today_outlined,
            label: 'Appointments',
            isSelected: _index == 2,
            onTap: () => _setTab(2),
          ),
          const SizedBox(height: 6),
          _SidebarItem(
            icon: Icons.medication_outlined,
            label: 'Prescriptions',
            isSelected: _index == 3,
            onTap: () => _setTab(3),
          ),
          const Spacer(),
          // User / Logout profile bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? user.name[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user?.name ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Clinic Admin',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Logout',
                  onPressed: () => context.read<AuthController>().logout(),
                  icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
