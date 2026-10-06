import '../core/api_client.dart';
import '../models/user.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _api.post<void>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
  }

  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) {
    return _api.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        return (
          token: map['token'] as String,
          user: User.fromJson(map['user'] as Map<String, dynamic>),
        );
      },
    );
  }
}
