import 'package:accurate/config/app_config.dart';
import 'package:accurate/models/authentication/login_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DemoAuthService {
  DemoAuthService._();

  static final DemoAuthService instance = DemoAuthService._();

  static const String demoUsername = 'admin';
  static const String demoPassword = 'admin123';
  static const String sessionKey = 'loginData';

  Future<LoginResponseModel> authenticate(
    String username,
    String password,
  ) async {
    await Future<void>.delayed(AppConfig.demoDelay);
    final isValid = username == demoUsername && password == demoPassword;
    return LoginResponseModel(
      statusCode: isValid ? 200 : 401,
      isSuccess: isValid,
      errorMessages:
          isValid ? <dynamic>[] : <dynamic>['Invalid username or password'],
      // The legacy model requires a string result. It is intentionally not a
      // credential or bearer token and is never persisted in demo mode.
      result: isValid ? 'demo-session' : '',
    );
  }

  Future<void> persistSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(sessionKey, true);
    await preferences.remove('loginToken');
    await preferences.remove('x-session-id');
  }

  Future<bool> hasActiveSession() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(sessionKey) ?? false;
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(sessionKey);
    await preferences.remove('loginToken');
    await preferences.remove('x-session-id');
  }
}
