import '../core/api_client.dart';
import '../models/prescription.dart';

class PrescriptionService {
  PrescriptionService(this._api);

  final ApiClient _api;

  Future<Prescription> create({
    required String patientId,
    required String diagnosis,
    required String medicines,
    String notes = '',
  }) {
    return _api.post(
      '/prescriptions',
      data: {
        'patientId': patientId,
        'diagnosis': diagnosis,
        'medicines': medicines,
        'notes': notes,
      },
      parser: (data) => Prescription.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Prescription>> search(String query) {
    return _api.get(
      '/prescriptions/search',
      query: {'q': query.trim()},
      parser: _list,
    );
  }

  Future<List<Prescription>> forPatient(String patientId) {
    return _api.get(
      '/prescriptions/patient/$patientId',
      parser: _list,
    );
  }

  List<Prescription> _list(dynamic data) {
    return (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Prescription.fromJson)
        .toList();
  }
}
