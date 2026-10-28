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
      backgroundColor: const Color(0xFFEDF2F6),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () => _openAdd(),
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('Add Rx', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _query,
                    decoration: const InputDecoration(
                      hintText: 'Search name, phone, or patient ID',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          if (_loading) const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
          if (_error != null) ErrorBanner(message: _error!),
          if (_searchResults != null) ...[
            const SizedBox(height: 18),
            Text(
              'Search results',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            if (_searchResults!.isEmpty)
              const EmptyState(message: 'No matching prescriptions.', icon: Icons.search_off_outlined)
            else
              ..._searchResults!.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.medication_outlined, size: 20, color: Color(0xFF1E293B)),
                    ),
                    title: Text(
                      '${item.patient?.name ?? 'Patient'} (${item.patient?.patientId ?? ''})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text('Diagnosis: ${item.diagnosis}\nRx: ${item.medicines}'),
                    isThreeLine: true,
                    onTap: () => _openAdd(seed: item),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPatientId,
                decoration: const InputDecoration(
                  labelText: 'Patient history',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                items: [
                  ..._patients.map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) _loadHistory(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_history.isEmpty)
            const EmptyState(
              message: 'Select a patient to view prescription history.',
              icon: Icons.history_rounded,
            )
          else
            ..._history.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFE2E8F0),
                    child: const Icon(Icons.receipt_long_outlined, size: 20, color: Color(0xFF1E293B)),
                  ),
                  title: Text(
                    item.patient?.name ?? 'Patient',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF1E293B),
                    ),
                  ),
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
