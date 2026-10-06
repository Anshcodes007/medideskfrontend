import '../core/api_client.dart';
import '../models/patient.dart';

class PatientService {
  PatientService(this._api);

  final ApiClient _api;

  Future<List<Patient>> list({String query = ''}) {
    return _api.get(
      '/patients',
      query: query.trim().isEmpty ? null : {'q': query.trim()},
      parser: (data) => (data as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Patient.fromJson)
          .toList(),
    );
  }

  Future<Patient> create({
    required String name,
    required int age,
    required String phone,
    String medicalInfo = '',
  }) {
    return _api.post(
      '/patients',
      data: {
        'name': name,
        'age': age,
        'phone': phone,
        'medicalInfo': medicalInfo,
      },
      parser: (data) => Patient.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Patient> update({
    required String id,
    required String name,
    required int age,
    required String phone,
    String medicalInfo = '',
  }) {
    return _api.put(
      '/patients/$id',
      data: {
        'name': name,
        'age': age,
        'phone': phone,
        'medicalInfo': medicalInfo,
      },
      parser: (data) => Patient.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> delete(String id) async {
    try {
      await _api.delete<dynamic>('/patients/$id');
    } catch (_) {
      await _api.post<dynamic>('/patients/$id/delete');
    }
  }
}
