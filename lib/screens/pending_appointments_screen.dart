import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/common.dart';

class PendingAppointmentsScreen extends StatefulWidget {
  const PendingAppointmentsScreen({super.key});

  @override
  State<PendingAppointmentsScreen> createState() => PendingAppointmentsScreenState();
}

class PendingAppointmentsScreenState extends State<PendingAppointmentsScreen> {
  List<Appointment> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<AppointmentService>().pending();
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _markDone(Appointment item) async {
    final index = _items.indexWhere((a) => a.id == item.id);
    if (index == -1) return;

    // Optimistically remove from pending appointments list
    setState(() {
      _items.removeAt(index);
    });

    try {
      await context.read<AppointmentService>().updateStatus(
            id: item.id,
            status: 'completed',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Appointment for ${item.patient?.name ?? 'patient'} marked as done',
          ),
          backgroundColor: const Color(0xFF16A34A),
          duration: const Duration(seconds: 2),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      // Revert if error
      setState(() {
        _items.insert(index, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _items.insert(index, item);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ErrorBanner(message: _error!),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                'Pending Appointments (${_items.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh',
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _items.isEmpty && !_loading
                ? ListView(
                    children: const [
                      SizedBox(height: 48),
                      EmptyState(
                        message: 'No pending appointments.\nAll appointments are completed.',
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  '#${item.queueNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.patient?.name ?? 'Unknown Patient',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (item.patient?.phone != null &&
                                        item.patient!.phone.isNotEmpty)
                                      Text(
                                        '📞 ${item.patient!.phone}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.date,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.time,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.reason.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Reason: ${item.reason}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          'Status: ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFDC2626),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: const Text(
                                            'not done',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFB91C1C),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Green tick button to mark done and remove from pending appointments
                              Tooltip(
                                message: 'Mark as done',
                                child: Material(
                                  color: const Color(0xFF16A34A),
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => _markDone(item),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
