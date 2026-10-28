import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../core/indian_phone.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key, this.patient});

  final Patient? patient;

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _phone;
  late final TextEditingController _medical;
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final patient = widget.patient;
    _name = TextEditingController(text: patient?.name ?? '');
    _age = TextEditingController(text: patient == null ? '' : '${patient.age}');
    _phone = TextEditingController(text: patient?.phone ?? '');
    _medical = TextEditingController(text: patient?.medicalInfo ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _medical.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final service = context.read<PatientService>();
      if (_isEdit) {
        await service.update(
          id: widget.patient!.id,
          name: _name.text.trim(),
          age: int.parse(_age.text.trim()),
          phone: _phone.text.trim(),
          medicalInfo: _medical.text.trim(),
        );
      } else {
        await service.create(
          name: _name.text.trim(),
          age: int.parse(_age.text.trim()),
          phone: _phone.text.trim(),
          medicalInfo: _medical.text.trim(),
        );
      }
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
      appBar: AppBar(title: Text(_isEdit ? 'Update patient' : 'Add patient')),
      body: SingleChildScrollView(
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
              if (_isEdit) ...[
                TextFormField(
                  initialValue: widget.patient!.patientId,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Patient ID'),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 0) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: indianMobileValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medical,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Basic medical info (optional)',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(
                  _busy
                      ? (_isEdit ? 'Updating…' : 'Saving…')
                      : (_isEdit ? 'Update patient' : 'Save patient'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
