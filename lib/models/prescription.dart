import 'patient.dart';

class Prescription {
  const Prescription({
    required this.id,
    required this.diagnosis,
    required this.medicines,
    this.notes = '',
    this.patient,
    this.createdAt,
  });

  final String id;
  final String diagnosis;
  final String medicines;
  final String notes;
  final Patient? patient;
  final DateTime? createdAt;

  factory Prescription.fromJson(Map<String, dynamic> json) {
    Patient? patient;
    final rawPatient = json['patient'];
    if (rawPatient is Map<String, dynamic>) {
      patient = Patient.fromJson(rawPatient);
    }

    return Prescription(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      diagnosis: json['diagnosis'] as String? ?? '',
      medicines: json['medicines'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      patient: patient,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
