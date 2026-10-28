import '../core/api_client.dart';
import '../models/appointment.dart';

class AppointmentService {
  AppointmentService(this._api);

  final ApiClient _api;

  Future<List<Appointment>> daily(String date) {
    return _api.get(
      '/appointments/daily',
      query: {'date': date},
      parser: _list,
    );
  }

  Future<List<Appointment>> pending() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return daily(today);
  }

  Future<List<Appointment>> search(String query) {
    return _api.get(
      '/appointments/search',
      query: {'q': query.trim()},
      parser: _list,
    );
  }

  Future<Appointment> book({
    required String patientId,
    required String date,
    required String time,
    String reason = '',
  }) {
    return _api.post(
      '/appointments',
      data: {
        'patientId': patientId,
        'date': date,
        'time': time,
        'reason': reason,
      },
      parser: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Appointment> updateStatus({
    required String id,
    required String status,
  }) {
    return _api.patch(
      '/appointments/$id/status',
      data: {'status': status},
      parser: (data) => Appointment.fromJson(data as Map<String, dynamic>),
    );
  }

  List<Appointment> _list(dynamic data) {
    return (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Appointment.fromJson)
        .toList();
  }
}
