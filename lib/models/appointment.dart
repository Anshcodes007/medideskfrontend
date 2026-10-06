import 'patient.dart';

class Appointment {
  const Appointment({
    required this.id,
    required this.appointmentId,
    required this.date,
    required this.time,
    required this.queueNumber,
    required this.status,
    this.reason = '',
    this.patient,
  });

  final String id;
  final String appointmentId;
  final String date;
  final String time;
  final int queueNumber;
  final String status;
  final String reason;
  final Patient? patient;

  bool get isCompleted => status == 'completed';

  factory Appointment.fromJson(Map<String, dynamic> json) {
    Patient? patient;
    final rawPatient = json['patient'];
    if (rawPatient is Map<String, dynamic>) {
      patient = Patient.fromJson(rawPatient);
    }

    return Appointment(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      appointmentId: json['appointmentId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      queueNumber: (json['queueNumber'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'scheduled',
      reason: json['reason'] as String? ?? '',
      patient: patient,
    );
  }
}
