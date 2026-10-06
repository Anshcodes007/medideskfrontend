import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../widgets/common.dart';
import 'add_patient_screen.dart';

class PatientDetailsScreen extends StatefulWidget {
  const PatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final _query = TextEditingController();
  List<Patient> _patients = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<PatientService>().list(query: _query.text);
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

  Future<void> _openUpdate(Patient patient) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddPatientScreen(patient: patient)),
    );
    if (updated == true) _load();
  }

  Future<void> _confirmDelete(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete patient'),
        content: Text(
          'Delete ${patient.name} (${patient.patientId})? Their appointments and prescriptions will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await context.read<PatientService>().delete(patient.id);
      if (!mounted) return;
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient details')),
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
                      hintText: 'Search name, phone, or patient ID',
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _load,
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
            child: RefreshIndicator(
              onRefresh: _load,
              child: _patients.isEmpty && !_loading
                  ? ListView(
                      children: const [EmptyState(message: 'No patients found.')],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                  title: Text('${patient.name} (${patient.patientId})'),
                                  subtitle: Text(
                                    '${patient.subtitle}${patient.medicalInfo.isEmpty ? '' : '\n${patient.medicalInfo}'}',
                                  ),
                                  isThreeLine: patient.medicalInfo.isNotEmpty,
                                ),
                                OverflowBar(
                                  alignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _openUpdate(patient),
                                      icon: const Icon(Icons.edit_outlined),
                                      label: const Text('Update'),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _confirmDelete(patient),
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Delete'),
                                    ),
                                  ],
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
      ),
    );
  }
}
