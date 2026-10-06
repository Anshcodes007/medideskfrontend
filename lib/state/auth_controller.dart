import 'package:flutter/foundation.dart';

import '../core/api_exception.dart';
import '../core/auth_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required AuthStorage storage,
  })  : _authService = authService,
        _storage = storage;

  final AuthService _authService;
  final AuthStorage _storage;

  User? user;
  bool restoring = true;
  bool busy = false;
  String? error;

  bool get isLoggedIn => user != null;

  Future<void> restore() async {
    restoring = true;
    notifyListeners();
    try {
      final token = await _storage.readToken();
      final saved = await _storage.readUser();
      if (token != null && token.isNotEmpty && saved != null) {
        user = saved;
      } else {
        await _storage.clear();
        user = null;
      }
    } catch (_) {
      user = null;
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    return _run(() async {
      final result = await _authService.login(email: email, password: password);
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user);
      user = result.user;
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(() async {
      await _authService.register(name: name, email: email, password: password);
      final result = await _authService.login(email: email, password: password);
      await _storage.saveToken(result.token);
      await _storage.saveUser(result.user);
      user = result.user;
    });
  }

  Future<void> logout() async {
    await _storage.clear();
    user = null;
    error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Something went wrong';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
