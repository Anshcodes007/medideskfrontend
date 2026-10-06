import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/common.dart';

class AppointmentSearchScreen extends StatefulWidget {
  const AppointmentSearchScreen({super.key});

  @override
  State<AppointmentSearchScreen> createState() => _AppointmentSearchScreenState();
}

class _AppointmentSearchScreenState extends State<AppointmentSearchScreen> {
  final _query = TextEditingController();
  List<Appointment> _items = [];
  bool _loading = false;
  String? _error;
  bool _searched = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.text.trim().isEmpty) {
      setState(() {
        _items = [];
        _searched = true;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _searched = true;
    });
    try {
      final list = await context.read<AppointmentService>().search(_query.text);
      if (!mounted) return;
      setState(() {
        _items = list;
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

  Future<void> _toggle(Appointment item) async {
    final next = item.isCompleted ? 'scheduled' : 'completed';
    try {
      await context.read<AppointmentService>().updateStatus(
            id: item.id,
            status: next,
          );
      await _search();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search appointments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(
                      hintText: 'Name, phone, or patient ID',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ErrorBanner(message: _error!),
            ),
          Expanded(
            child: !_searched
                ? const EmptyState(message: 'Search a patient to see appointment history.')
                : _items.isEmpty && !_loading
                    ? const EmptyState(message: 'No appointment history found.')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.patient?.name ?? 'Patient'} (${item.patient?.phone ?? ''})',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(item.isCompleted ? 'Done' : 'Not done'),
                                        backgroundColor: item.isCompleted
                                            ? const Color(0xFFDCFCE7)
                                            : const Color(0xFFFEE2E2),
                                      ),
                                    ],
                                  ),
                                  Text('ID: ${item.appointmentId}'),
                                  Text('Date: ${item.date}  Time: ${item.time}'),
                                  const SizedBox(height: 8),
                                  FilledButton(
                                    onPressed: () => _toggle(item),
                                    child: Text(
                                      item.isCompleted ? 'Mark not done' : 'Mark done',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
