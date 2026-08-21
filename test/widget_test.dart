import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/utils/splash_screen.dart';
import 'package:accurate/views/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('Splash routes a logged-out user to login after its timer',
      (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: RoutesManager.getSplashRoute(),
        defaultTransition: Transition.noTransition,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: RoutesManager.getSplashRoute(),
            page: () => const SplashScreen(),
          ),
          GetPage<dynamic>(
            name: RoutesManager.getLoginRoute(),
            page: () => const Scaffold(body: Text('Demo login route')),
          ),
        ],
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Demo login route'), findsOneWidget);
    expect(Get.currentRoute, RoutesManager.getLoginRoute());
  });

  testWidgets('Splash restores a persisted demo session', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'loginData': true,
    });

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: RoutesManager.getSplashRoute(),
        defaultTransition: Transition.noTransition,
        getPages: <GetPage<dynamic>>[
          GetPage<dynamic>(
            name: RoutesManager.getSplashRoute(),
            page: () => const SplashScreen(),
          ),
          GetPage<dynamic>(
            name: RoutesManager.getDashboardRoute(),
            page: () => const Scaffold(body: Text('Demo dashboard route')),
          ),
        ],
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Demo dashboard route'), findsOneWidget);
    expect(Get.currentRoute, RoutesManager.getDashboardRoute());
  });

  testWidgets('Login accepts demo credentials and persists the session',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_loginTestApp());
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Demo dashboard route'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('loginData'), isTrue);
    expect(preferences.getString('loginToken'), isNull);

    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Login rejects incorrect credentials and stops its loader',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_loginTestApp());
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'incorrect');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Invalid username or password'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('loginData'), isNot(isTrue));

    await tester.pump(const Duration(seconds: 4));
  });
}

Widget _loginTestApp() => GetMaterialApp(
      initialRoute: RoutesManager.getLoginRoute(),
      defaultTransition: Transition.noTransition,
      getPages: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: RoutesManager.getLoginRoute(),
          page: () => LoginPage(),
        ),
        GetPage<dynamic>(
          name: RoutesManager.getDashboardRoute(),
          page: () => const Scaffold(body: Text('Demo dashboard route')),
        ),
      ],
    );
