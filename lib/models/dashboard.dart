import 'appointment.dart';
import 'prescription.dart';

class DashboardData {
  const DashboardData({
    required this.totalPatients,
    required this.todaysAppointments,
    required this.recentVisits,
  });

  final int totalPatients;
  final List<Appointment> todaysAppointments;
  final List<Prescription> recentVisits;

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      totalPatients: (json['totalPatients'] as num?)?.toInt() ?? 0,
      todaysAppointments: (json['todaysAppointments'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Appointment.fromJson)
          .toList(),
      recentVisits: (json['recentVisits'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(Prescription.fromJson)
          .toList(),
    );
  }

  static const empty = DashboardData(
    totalPatients: 0,
    todaysAppointments: [],
    recentVisits: [],
  );
}
