import 'package:accurate/config/app_config.dart';
import 'package:accurate/data/local/dummy_data.dart';
import 'package:accurate/repositories/mock_store_repository.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repository = MockStoreRepository.instance;

  setUp(repository.resetSessionState);

  test('returns at least ten demo products', () async {
    final response = await repository.getProducts(1, 100, '', '', 10000, 0);

    expect(response.isSuccess, isTrue);
    expect(response.result.products.totalCount, greaterThanOrEqualTo(10));
    expect(response.result.products.data, hasLength(greaterThanOrEqualTo(10)));
  });

  test('central catalog contains complete realistic product metadata', () {
    expect(DummyData.products, hasLength(greaterThanOrEqualTo(10)));
    for (final product in DummyData.products) {
      expect(product.name, isNotEmpty);
      expect(product.description, isNotEmpty);
      expect(product.categoryName, isNotEmpty);
      expect(product.originalPrice, greaterThan(0));
      expect(product.discountedPrice, lessThan(product.originalPrice));
      expect(product.rating, inInclusiveRange(1, 5));
      expect(product.reviewCount, greaterThan(0));
      expect(product.stockQuantity, greaterThan(0));
      expect(product.sku, isNotEmpty);
      expect(product.brand, isNotEmpty);
      expect(product.imageAsset, startsWith('assets/'));
      expect(product.isAvailable, isTrue);
    }
  });

  test('RemoteService dispatches to local data while offline mode is enabled',
      () async {
    expect(AppConfig.useOfflineMode, isTrue);
    final response = await RemoteService.getCategory(1, 10);
    expect(response.isSuccess, isTrue);
    expect(response.result.data, isNotEmpty);
  });

  test('filters products by category and search text', () async {
    final audio = await repository.getProducts(1, 100, '', '', 10000, 1);
    expect(audio.result.products.data, isNotEmpty);
    expect(
      audio.result.products.data.map((product) => product.productCode),
      containsAll(<String>['DEMO-001', 'DEMO-007']),
    );
    expect(
      audio.result.products.data.every(
        (product) =>
            <String>['DEMO-001', 'DEMO-007'].contains(product.productCode),
      ),
      isTrue,
    );

    final keyboard =
        await repository.getProducts(1, 100, 'keyboard', '', 10000, 0);
    expect(keyboard.result.products.totalCount, 1);
    expect(
      keyboard.result.products.data.single.productName,
      'Mechanical Keyboard',
    );
  });

  test('cart additions and removals remain local and mutable', () async {
    const productCode = 'DEMO-003';
    var cart = await repository.getCart();
    expect(
      cart.result.any((product) => product.productCode == productCode),
      isFalse,
    );

    final added = await repository.addToCart(productCode);
    expect(added.isSuccess, isTrue);

    cart = await repository.getCart();
    final addedItem = cart.result
        .singleWhere((product) => product.productCode == productCode);

    final deleted = await repository.deleteCartItem(addedItem.cartId);
    expect(deleted.isSuccess, isTrue);

    cart = await repository.getCart();
    expect(
      cart.result.any((product) => product.productCode == productCode),
      isFalse,
    );
  });

  test('wishlist toggles remain local and mutable', () async {
    const productCode = 'DEMO-002';
    var wishlist = await repository.getWishlist();
    expect(
      wishlist.result.any((product) => product.productCode == productCode),
      isFalse,
    );

    final added = await repository.toggleWishlist(productCode);
    expect(added.isSuccess, isTrue);
    wishlist = await repository.getWishlist();
    expect(
      wishlist.result.any((product) => product.productCode == productCode),
      isTrue,
    );

    final removed = await repository.toggleWishlist(productCode);
    expect(removed.isSuccess, isTrue);
    wishlist = await repository.getWishlist();
    expect(
      wishlist.result.any((product) => product.productCode == productCode),
      isFalse,
    );
  });

  test(
      'checkout creates viewable order history and removes purchased cart item',
      () async {
    final before = await repository.getOrders();
    final placed = await repository.placeOrder(<String, dynamic>{
      'address': '99 Offline Test Road',
      'orderDetails': <Map<String, dynamic>>[
        <String, dynamic>{
          'companyId': 2,
          'attributeValueId': 0,
          'qty': 2,
          'productCode': 'DEMO-002',
        },
      ],
    });
    expect(placed.isSuccess, isTrue);

    final after = await repository.getOrders();
    expect(after.result.length, before.result.length + 1);
    final createdOrder = after.result.first;
    final details = await repository.getOrderDetails(createdOrder.id);
    expect(details.result.address, '99 Offline Test Road');
    expect(details.result.orderItems.single.quantity, 2);

    final cart = await repository.getCart();
    expect(
      cart.result.any((product) => product.productCode == 'DEMO-002'),
      isFalse,
    );
  });

  test('addresses can be added and deleted locally', () async {
    const newAddress = '27 Local Demo Avenue';
    final added = await repository.addAddress(newAddress);
    expect(added.isSuccess, isTrue);

    var addresses = await repository.getAddresses();
    final created =
        addresses.result.singleWhere((address) => address.name == newAddress);

    final deleted = await repository.deleteAddress(created.id);
    expect(deleted.isSuccess, isTrue);
    addresses = await repository.getAddresses();
    expect(
      addresses.result.any((address) => address.id == created.id),
      isFalse,
    );
  });
}
