import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/prescription_pdf.dart';
import '../services/patient_service.dart';
import '../services/prescription_service.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({
    super.key,
    this.patients = const [],
    this.seed,
  });

  final List<Patient> patients;
  final Prescription? seed;

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosis = TextEditingController();
  final _medicines = TextEditingController();
  final _notes = TextEditingController();
  String? _patientId;
  bool _busy = false;
  String? _error;
  late List<Patient> _patients;
  bool _loadingPatients = false;

  @override
  void initState() {
    super.initState();
    _patients = List.of(widget.patients);
    final seed = widget.seed;
    if (seed != null) {
      _patientId = seed.patient?.id;
      _diagnosis.text = seed.diagnosis;
      _medicines.text = seed.medicines;
      _notes.text = seed.notes;
    }
    if (_patients.isEmpty) {
      _fetchPatients();
    }
  }

  Future<void> _fetchPatients() async {
    setState(() => _loadingPatients = true);
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

  @override
  void dispose() {
    _diagnosis.dispose();
    _medicines.dispose();
    _notes.dispose();
    super.dispose();
  }

  Patient? get _selectedPatient {
    try {
      return _patients.firstWhere((p) => p.id == _patientId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<PrescriptionService>().create(
            patientId: _patientId!,
            diagnosis: _diagnosis.text.trim(),
            medicines: _medicines.text.trim(),
            notes: _notes.text.trim(),
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

  Future<void> _print() async {
    final patient = _selectedPatient;
    if (patient == null ||
        _diagnosis.text.trim().isEmpty ||
        _medicines.text.trim().isEmpty) {
      setState(() => _error = 'Select patient and fill diagnosis/medicines before printing');
      return;
    }
    await PrescriptionPdf.print(
      patient: patient,
      diagnosis: _diagnosis.text.trim(),
      medicines: _medicines.text.trim(),
      notes: _notes.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription')),
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
              if (_loadingPatients) const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(),
              ),
              if (_patients.isEmpty && !_loadingPatients && _error == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No patients found. Please add a patient first from the Patients tab.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              DropdownButtonFormField<String>(
                key: ValueKey(_patients.length),
                initialValue: _patientId,
                items: _patients
                    .map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.name} (${p.patientId})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _patientId = v),
                decoration: const InputDecoration(labelText: 'Patient'),
                validator: (v) => v == null ? 'Select a patient' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _diagnosis,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _medicines,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Medicines'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Saving…' : 'Save prescription'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _print,
                child: const Text('Print prescription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
