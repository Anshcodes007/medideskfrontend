import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/dashboard.dart';
import '../services/dashboard_service.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardData _data = DashboardData.empty;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await context.read<DashboardService>().load();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) ErrorBanner(message: _error!),
          if (_loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          MetricCard(label: 'Total patients', value: '${_data.totalPatients}'),
          const SizedBox(height: 12),
          MetricCard(
            label: "Today's appointments",
            value: '${_data.todaysAppointments.length}',
          ),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Recent visits',
            value: '${_data.recentVisits.length}',
          ),
          const SizedBox(height: 20),
          Text("Today's queue", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_data.todaysAppointments.isEmpty)
            const EmptyState(message: 'No appointments today.')
          else
            ..._data.todaysAppointments.map(
              (item) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('#${item.queueNumber}')),
                  title: Text(item.patient?.name ?? 'Patient'),
                  subtitle: Text(
                    '${item.time} · ${item.patient?.phone ?? ''}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
