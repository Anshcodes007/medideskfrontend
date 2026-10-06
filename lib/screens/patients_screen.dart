import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exception.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';
import '../widgets/common.dart';
import 'add_patient_screen.dart';
import 'patient_details_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
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

  Future<void> _openAdd() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddPatientScreen()),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.person_add),
        label: const Text('Add patient'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
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
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PatientDetailsScreen(),
                      ),
                    );
                    if (mounted) _load();
                  },
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('Patient details'),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return Card(
                          child: ListTile(
                            title: Text('${patient.name} (${patient.patientId})'),
                            subtitle: Text(
                              '${patient.subtitle}${patient.medicalInfo.isEmpty ? '' : '\n${patient.medicalInfo}'}',
                            ),
                            isThreeLine: patient.medicalInfo.isNotEmpty,
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
