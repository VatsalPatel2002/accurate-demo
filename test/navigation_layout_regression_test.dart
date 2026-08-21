import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/dashboard/dashboard_controller.dart';
import 'package:accurate/repositories/mock_store_repository.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/views/dashboard/dashboard.dart';
import 'package:accurate/views/layout/product.dart';
import 'package:accurate/views/layout/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'loginData': true,
    });
    MockStoreRepository.instance.resetSessionState();
    Get.testMode = true;
  });

  tearDown(() async {
    await Get.deleteAll(force: true);
    Get.reset();
  });

  testWidgets('dashboard category cards fit the iPhone 16e viewport',
      (tester) async {
    _useIPhone16eViewport(tester);

    await tester.pumpWidget(_catalogTestApp());
    await _finishDemoRequest(tester);

    expect(find.byType(Dashboard), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Computer Accessories'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _disposeTestApp(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'dashboard to product and details navigation keeps controllers alive '
      'and product cards within bounds', (tester) async {
    _useIPhone16eViewport(tester);

    await tester.pumpWidget(_catalogTestApp());
    await _finishDemoRequest(tester);
    expect(tester.takeException(), isNull);
    final sharedDashboard = Get.find<DashboardController>();

    await tester.scrollUntilVisible(
      find.text('Audio'),
      450,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Audio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byType(Product), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _finishDemoRequest(tester);

    expect(find.text('Wireless Bluetooth Headphones'), findsOneWidget);
    expect(find.text('Portable Bluetooth Speaker'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Wireless Bluetooth Headphones'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(find.byType(ProductDetails), findsOneWidget);
    expect(Get.find<DashboardController>(), same(sharedDashboard));
    await _finishDemoRequest(tester);
    await tester.enterText(
      find.byKey(const Key('product-details-search')),
      'headphones',
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await _disposeTestApp(tester);
    expect(tester.takeException(), isNull);
  });
}

void _useIPhone16eViewport(WidgetTester tester) {
  // iPhone 16e reports a 390 x 844 logical-pixel viewport. This is the size
  // that previously produced 172 x 172 grid cells and an 11-pixel overflow.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _catalogTestApp() => GetMaterialApp(
      defaultTransition: Transition.noTransition,
      initialBinding: BindingsBuilder(AppControllers.initialize),
      initialRoute: RoutesManager.getDashboardRoute(),
      getPages: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: RoutesManager.getDashboardRoute(),
          page: () => const Dashboard(),
        ),
        GetPage<dynamic>(
          name: RoutesManager.getProductList(),
          page: () => const Product(),
        ),
        GetPage<dynamic>(
          name: RoutesManager.getProductDetails(),
          page: () => const ProductDetails(),
        ),
      ],
    );

Future<void> _finishDemoRequest(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 450));
  await tester.pumpAndSettle();
}

Future<void> _disposeTestApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
}
