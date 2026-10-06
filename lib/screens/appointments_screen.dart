import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/common.dart';
import 'appointment_search_screen.dart';
import 'book_appointment_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late DateTime _date;
  List<Appointment> _items = [];
  bool _loading = true;
  String? _error;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<AppointmentService>().daily(_dateStr);
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    await _load();
  }

  Future<void> _openBook() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookAppointmentScreen(initialDate: _dateStr),
      ),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBook,
        icon: const Icon(Icons.event_available),
        label: const Text('Book slot'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_dateStr),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppointmentSearchScreen(),
                    ),
                  ),
                  child: const Text('Search'),
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
            child: RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty && !_loading
                  ? ListView(
                      children: const [
                        EmptyState(message: 'No scheduled appointments for this date.'),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('#${item.queueNumber}')),
                            title: Text('${item.time} · ${item.patient?.name ?? 'Patient'}'),
                            subtitle: Text(
                              '${item.patient?.phone ?? ''}${item.reason.isEmpty ? '' : '\n${item.reason}'}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
