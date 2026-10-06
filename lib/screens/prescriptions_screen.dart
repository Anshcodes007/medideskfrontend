import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/patient_service.dart';
import '../services/prescription_service.dart';
import '../widgets/common.dart';
import 'add_prescription_screen.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  final _query = TextEditingController();
  List<Patient> _patients = [];
  List<Prescription> _history = [];
  List<Prescription>? _searchResults;
  String? _selectedPatientId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final list = await context.read<PatientService>().list();
      if (!mounted) return;
      setState(() {
        _patients = list;
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

  Future<void> _search() async {
    if (_query.text.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<PrescriptionService>().search(_query.text);
      if (!mounted) return;
      setState(() {
        _searchResults = list;
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

  Future<void> _loadHistory(String patientId) async {
    setState(() {
      _selectedPatientId = patientId;
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<PrescriptionService>().forPatient(patientId);
      if (!mounted) return;
      setState(() {
        _history = list;
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

  Future<void> _openAdd({Prescription? seed}) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddPrescriptionScreen(
          patients: _patients,
          seed: seed,
        ),
      ),
    );
    if (created == true && _selectedPatientId != null) {
      await _loadHistory(_selectedPatientId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(),
        icon: const Icon(Icons.note_add),
        label: const Text('Add Rx'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _query,
                  decoration: const InputDecoration(
                    hintText: 'Search name, phone, or patient ID',
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
          if (_loading) const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
          if (_error != null) ErrorBanner(message: _error!),
          if (_searchResults != null) ...[
            const SizedBox(height: 16),
            Text('Search results', style: Theme.of(context).textTheme.titleMedium),
            if (_searchResults!.isEmpty)
              const EmptyState(message: 'No matching prescriptions.')
            else
              ..._searchResults!.map(
                (item) => Card(
                  child: ListTile(
                    title: Text(
                      '${item.patient?.name ?? 'Patient'} (${item.patient?.patientId ?? ''})',
                    ),
                    subtitle: Text('Diagnosis: ${item.diagnosis}\nRx: ${item.medicines}'),
                    isThreeLine: true,
                    onTap: () => _openAdd(seed: item),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedPatientId,
            decoration: const InputDecoration(labelText: 'Patient history'),
            items: [
              ..._patients.map(
                (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
              ),
            ],
            onChanged: (v) {
              if (v != null) _loadHistory(v);
            },
          ),
          const SizedBox(height: 12),
          if (_history.isEmpty)
            const EmptyState(message: 'Select a patient to view prescription history.')
          else
            ..._history.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.patient?.name ?? 'Patient'),
                  subtitle: Text('Diagnosis: ${item.diagnosis}\nRx: ${item.medicines}'),
                  isThreeLine: true,
                  onTap: () => _openAdd(seed: item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
