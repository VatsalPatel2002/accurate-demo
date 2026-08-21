import 'package:accurate/controllers/layout/my_cart_controller.dart';
import 'package:accurate/controllers/layout/product_details_controller.dart';
import 'package:accurate/models/cart/cart_response_model.dart' as cart;
import 'package:accurate/models/product/product_details_response_model.dart'
    as details;
import 'package:accurate/repositories/mock_store_repository.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/views/layout/my_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MyCartController interaction safety', () {
    late MyCartController controller;

    setUp(() {
      MockStoreRepository.instance.resetSessionState();
      controller = MyCartController();
    });

    tearDown(() {
      controller.onClose();
    });

    test('quantity controls clamp at one and the maximum', () {
      controller.countList.add(<String, dynamic>{
        'qty': 1,
        'productCode': 'TEST-001',
      });

      controller.decrementQuantity(0);
      expect(controller.quantityAt(0), 1);

      controller.countList[0] = <String, dynamic>{
        'qty': MyCartController.maxQuantity,
        'productCode': 'TEST-001',
      };
      controller.incrementQuantity(0);
      expect(controller.quantityAt(0), MyCartController.maxQuantity);
    });

    test('malformed quantities normalize without throwing', () {
      controller.countList.assignAll(<Map<String, dynamic>>[
        <String, dynamic>{'qty': null},
        <String, dynamic>{'qty': 'not-a-number'},
        <String, dynamic>{'qty': -4},
        <String, dynamic>{'qty': 500},
      ]);

      expect(controller.quantityAt(0), 1);
      expect(controller.quantityAt(1), 1);
      expect(controller.quantityAt(2), 1);
      expect(controller.quantityAt(3), MyCartController.maxQuantity);
      expect(controller.quantityAt(-1), 1);
      expect(controller.quantityAt(99), 1);

      expect(() => controller.incrementQuantity(99), returnsNormally);
      expect(() => controller.decrementQuantity(-1), returnsNormally);

      controller.incrementQuantity(1);
      expect(controller.quantityAt(1), 2);
    });

    test('stale parallel cart state remains safe and cannot be ordered',
        () async {
      controller.cartList.add(_cartProduct());
      controller.countList.add(<String, dynamic>{'qty': 2});

      expect(controller.priceAt(0), isNull);
      expect(controller.priceAt(-1), isNull);
      expect(controller.updateData('company', 2, 0), isFalse);
      expect(() => controller.totalPriceCalculate(), returnsNormally);
      expect(controller.finalTotalPrice.value, '0.00');
      expect(await controller.postOrder(), isFalse);
      expect(controller.errorMessage.value, 'Your cart has no orderable items');

      controller.pricesData.add(_cartPrice(1, 10, 1200));
      controller.countList.clear();
      expect(() => controller.totalPriceCalculate(), returnsNormally);
      expect(() => controller.incrementQuantity(0), returnsNormally);
      expect(await controller.postOrder(), isFalse);
    });

    test('sparse company and attribute prices fall back to a valid variant',
        () {
      final first = _cartPrice(1, 10, 1200);
      final second = _cartPrice(2, 20, 1500);
      controller.cartList.add(
        _cartProduct(prices: <cart.Price>[first, second]),
      );
      controller.pricesData.add(first);
      controller.countList.add(<String, dynamic>{'qty': 1});

      expect(controller.updateData('company', 2, 0), isTrue);
      expect(controller.priceAt(0)?.companyId, 2);
      expect(controller.priceAt(0)?.attributeId, 20);

      expect(controller.updateData('attribute', 10, 0), isTrue);
      expect(controller.priceAt(0)?.companyId, 1);
      expect(controller.priceAt(0)?.attributeId, 10);

      expect(controller.updateData('company', 999, 0), isFalse);
      expect(controller.priceAt(0)?.companyId, 1);
      expect(controller.errorMessage.value,
          'Pricing is unavailable for this selection');
      expect(controller.updateData('unknown', 1, 0), isFalse);
      expect(controller.updateData('company', null, 0), isFalse);
    });

    test('checkout submits the saved address shown by the dropdown', () async {
      await controller.getCartList();
      expect(await controller.fetchSavedAddresses(), isTrue);
      final visibleAddress = controller.savedAddresses.last;
      controller.selectedAddressOption.value = 1;
      controller.selectedSavedAddress.value = visibleAddress;
      controller.addressController.text = 'Hidden custom address';

      expect(await controller.postOrder(), isTrue);
      final orders = await MockStoreRepository.instance.getOrders();
      final details = await MockStoreRepository.instance
          .getOrderDetails(orders.result.first.id);

      expect(details.result.address, visibleAddress);
    });
  });

  group('ProductDetailsController interaction safety', () {
    late ProductDetailsController controller;

    setUp(() {
      MockStoreRepository.instance.resetSessionState();
      controller = ProductDetailsController();
    });

    tearDown(() {
      controller.onClose();
    });

    test('quantity controls normalize and clamp at both boundaries', () {
      controller.count.value = 1;
      controller.decrementQuantity();
      expect(controller.count.value, 1);

      controller.count.value = ProductDetailsController.maxQuantity;
      controller.incrementQuantity();
      expect(controller.count.value, ProductDetailsController.maxQuantity);

      controller.count.value = 0;
      controller.decrementQuantity();
      expect(controller.count.value, 1);

      controller.count.value = 500;
      controller.incrementQuantity();
      expect(controller.count.value, ProductDetailsController.maxQuantity);
    });

    test('sparse variants switch to the first compatible price safely', () {
      final first = _detailsPrice(1, 10, 1200);
      final second = _detailsPrice(2, 20, 1500);
      controller.productDetails.value = _productDetails(
        prices: <details.Price>[first, second],
      );
      controller.pricesData.add(first);

      expect(controller.updateData('company', 2), isTrue);
      expect(controller.selectedPrice?.companyId, 2);
      expect(controller.selectedPrice?.attributeId, 20);

      expect(controller.updateData('attribute', 10), isTrue);
      expect(controller.selectedPrice?.companyId, 1);
      expect(controller.selectedPrice?.attributeId, 10);

      expect(controller.updateData('attribute', 999), isFalse);
      expect(controller.selectedPrice?.attributeId, 10);
      expect(controller.errorMessage.value,
          'Pricing is unavailable for this selection');
      expect(controller.updateData('unknown', 1), isFalse);
      expect(controller.updateData('company', null), isFalse);
    });

    test('variant changes are ignored safely when detail state is stale', () {
      expect(controller.selectedPrice, isNull);
      expect(controller.updateData('company', 1), isFalse);

      controller.productDetails.value = _productDetails(
        prices: <details.Price>[_detailsPrice(1, 10, 1200)],
      );
      expect(controller.updateData('attribute', 10), isFalse);
    });

    test('buy now submits the saved address displayed to the user', () async {
      final price = _detailsPrice(1, 10, 1200);
      controller.productDetails.value = _productDetails(
        prices: <details.Price>[price],
      );
      controller.pricesData.add(price);
      controller.productCode = 'DEMO-001';

      expect(await controller.fetchSavedAddresses(), isTrue);
      final visibleAddress = controller.savedAddresses.last;
      controller.selectedAddressOption.value = 1;
      controller.selectedSavedAddress.value = visibleAddress;
      controller.addressController.text = 'Hidden custom address';

      expect(await controller.postOrder(), isTrue);
      final orders = await MockStoreRepository.instance.getOrders();
      final order = await MockStoreRepository.instance
          .getOrderDetails(orders.result.first.id);

      expect(order.result.address, visibleAddress);
    });
  });

  group('UserProfile end drawer', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'loginData': true,
      });
      MockStoreRepository.instance.resetSessionState();
      Get.testMode = true;
    });

    tearDown(Get.reset);

    testWidgets('opens on a compact screen and shows addresses and orders',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            endDrawer: const UserProfile(),
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  child: const Text('Open profile'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.text('Demo Admin'), findsOneWidget);
      expect(find.text('Saved Addresses'), findsOneWidget);
      expect(
        find.text(
          '12 Demo Street, Navrangpura, Ahmedabad, Gujarat 380009',
        ),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.text('Your Orders'),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Orders'), findsOneWidget);
      expect(find.text('Order #1001'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Order #1001'));
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Order Details'), findsOneWidget);
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('Wireless Bluetooth Headphones'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('remains scrollable on a compact screen with 2x text',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: Scaffold(
            endDrawer: const UserProfile(),
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: Scaffold.of(context).openEndDrawer,
                  child: const Text('Open profile'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open profile'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Compact cart checkout', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'loginData': true,
      });
      MockStoreRepository.instance.resetSessionState();
      Get.testMode = true;
    });

    tearDown(Get.reset);

    testWidgets('opens without overflow at 320px and 2x text', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          ),
          home: const MyCart(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pumpAndSettle();

      final checkoutButton = find.text('Proceed to Checkout');
      await tester.scrollUntilVisible(
        checkoutButton,
        450,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(checkoutButton);
      await tester.pump(const Duration(milliseconds: 450));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Your Order'), findsOneWidget);
      expect(find.text('Cash On Delivery'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

cart.Price _cartPrice(int companyId, int attributeId, int price) => cart.Price(
      companyId: companyId,
      attributeId: attributeId,
      price: price,
      discount: 10,
    );

cart.ProductResult _cartProduct({List<cart.Price>? prices}) =>
    cart.ProductResult(
      cartId: 1,
      productId: 1,
      productName: 'Test Product',
      productImage:
          'assets/products/demo_001_wireless_bluetooth_headphones.png',
      productCode: 'TEST-001',
      attributeName: 'Size',
      isCompany: true,
      isAttribute: true,
      attributeId: 10,
      prices: prices ?? <cart.Price>[],
      company: <cart.Company>[
        cart.Company(id: 1, name: 'Company One'),
        cart.Company(id: 2, name: 'Company Two'),
      ],
      attributeValues: <cart.AttributeValue>[
        cart.AttributeValue(id: 10, name: 'Small'),
        cart.AttributeValue(id: 20, name: 'Large'),
      ],
    );

details.Price _detailsPrice(int companyId, int attributeId, int price) =>
    details.Price(
      companyId: companyId,
      attributeId: attributeId,
      price: price,
      discount: 10,
    );

details.Result _productDetails({required List<details.Price> prices}) =>
    details.Result(
      productId: 1,
      productName: 'Test Product',
      productImage:
          'assets/products/demo_001_wireless_bluetooth_headphones.png',
      description: 'Test product description',
      attributeName: 'Size',
      isCompany: true,
      isAttribute: true,
      productCode: 'TEST-001',
      isAddToCart: false,
      prices: prices,
      company: <details.Company>[
        details.Company(id: 1, name: 'Company One'),
        details.Company(id: 2, name: 'Company Two'),
      ],
      attributeValues: <details.AttributeValue>[
        details.AttributeValue(id: 10, name: 'Small'),
        details.AttributeValue(id: 20, name: 'Large'),
      ],
    );
