import '../core/api_client.dart';
import '../models/dashboard.dart';

class DashboardService {
  DashboardService(this._api);

  final ApiClient _api;

  Future<DashboardData> load() {
    return _api.get(
      '/dashboard',
      parser: (data) => DashboardData.fromJson(data as Map<String, dynamic>),
    );
  }
}
