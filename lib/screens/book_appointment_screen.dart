import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/patient.dart';
import '../services/appointment_service.dart';
import '../services/patient_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.initialDate});

  final String initialDate;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  List<Patient> _patients = [];
  String? _patientId;
  late DateTime _date;
  TimeOfDay? _time;
  bool _busy = false;
  bool _loadingPatients = true;
  String? _error;

  String get _dateStr => DateFormat('yyyy-MM-dd').format(_date);

  String _timeStr(TimeOfDay time) {
    final dt = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  void initState() {
    super.initState();
    _date = DateTime.tryParse(widget.initialDate) ?? DateTime.now();
    _loadPatients();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final list = await context.read<PatientService>().list();
      if (!mounted) return;
      setState(() {
        _patients = list;
        _loadingPatients = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingPatients = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_time == null) {
      setState(() => _error = 'Choose a time');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AppointmentService>().book(
            patientId: _patientId!,
            date: _dateStr,
            time: _timeStr(_time!),
            reason: _reason.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book appointment')),
      body: _loadingPatients
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    DropdownButtonFormField<String>(
                      initialValue: _patientId,
                      items: _patients
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.name} (${p.phone})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _patientId = v),
                      decoration: const InputDecoration(labelText: 'Patient'),
                      validator: (v) => v == null ? 'Select a patient' : null,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Date: $_dateStr'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _time == null ? 'Time: choose' : 'Time: ${_timeStr(_time!)}',
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _time ?? TimeOfDay.now(),
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                    ),
                    TextFormField(
                      controller: _reason,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Reason (optional)'),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _save,
                      child: Text(_busy ? 'Booking…' : 'Book slot'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
