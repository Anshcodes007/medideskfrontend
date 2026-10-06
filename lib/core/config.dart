/// Default API base. Override at run time with:
/// `--dart-define=API_BASE_URL=http://10.56.47.45:4000/api`
class ApiConfig {
  static const String _fromDefine = String.fromEnvironment('API_BASE_URL');
  static const String _defaultBaseUrl = 'https://medideskbackend.onrender.com/api';

  static String get baseUrl {
    final raw = _fromDefine.isNotEmpty ? _fromDefine : _defaultBaseUrl;
    return raw.replaceAll(' ', '');
  }
}
