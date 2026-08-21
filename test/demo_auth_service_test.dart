import 'package:accurate/services/demo_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('accepts exactly admin/admin123', () async {
    final response = await DemoAuthService.instance.authenticate(
      DemoAuthService.demoUsername,
      DemoAuthService.demoPassword,
    );

    expect(response.isSuccess, isTrue);
    expect(response.statusCode, 200);
    expect(response.errorMessages, isEmpty);
  });

  test('rejects incorrect or differently-cased credentials', () async {
    final attempts = await Future.wait([
      DemoAuthService.instance.authenticate('Admin', 'admin123'),
      DemoAuthService.instance.authenticate('admin', 'Admin123'),
      DemoAuthService.instance.authenticate('admin ', 'admin123'),
      DemoAuthService.instance.authenticate('admin', 'wrong-password'),
    ]);

    for (final response in attempts) {
      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 401);
      expect(response.errorMessages, contains('Invalid username or password'));
    }
  });

  test('persists and clears only the local session flag', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'loginToken': 'legacy-token',
      'x-session-id': 'legacy-session-id',
    });

    await DemoAuthService.instance.persistSession();

    var preferences = await SharedPreferences.getInstance();
    expect(await DemoAuthService.instance.hasActiveSession(), isTrue);
    expect(preferences.getBool(DemoAuthService.sessionKey), isTrue);
    expect(preferences.getString('loginToken'), isNull);
    expect(preferences.getString('x-session-id'), isNull);
    expect(
      preferences.getKeys().map(preferences.get),
      isNot(contains('demo-session')),
    );

    await DemoAuthService.instance.clearSession();

    preferences = await SharedPreferences.getInstance();
    expect(await DemoAuthService.instance.hasActiveSession(), isFalse);
    expect(preferences.containsKey(DemoAuthService.sessionKey), isFalse);
    expect(preferences.getString('loginToken'), isNull);
    expect(preferences.getString('x-session-id'), isNull);
  });
}
