import 'dart:convert';

import 'package:accurate/config/app_config.dart';
import 'package:accurate/data/local/dummy_data.dart';
import 'package:accurate/models/cart/add_to_cart_response_model.dart'
    as add_cart;
import 'package:accurate/models/cart/cart_response_model.dart' as cart;
import 'package:accurate/models/cart/delete_cart_response_model.dart'
    as delete_cart;
import 'package:accurate/models/cart/place_order_cart_response_model.dart'
    as place_order;
import 'package:accurate/models/contact_us/contact_response_model.dart'
    as contact;
import 'package:accurate/models/dashboard/address_by_userId_response_model.dart'
    as address;
import 'package:accurate/models/dashboard/category_response_model.dart'
    as category;
import 'package:accurate/models/dashboard/orders_response_model.dart' as orders;
import 'package:accurate/models/dashboard/user_details_response_model.dart'
    as user_details;
import 'package:accurate/models/dashboard/view_order_response_model.dart'
    as view_order;
import 'package:accurate/models/product/product_details_response_model.dart'
    as product_details;
import 'package:accurate/models/product/product_response_model.dart'
    as product_list;
import 'package:accurate/models/wishlist/remove_wishlist_response_model.dart'
    as remove_wishlist;
import 'package:accurate/models/wishlist/wishlist_response_model.dart'
    as wishlist;

/// Stateful, process-local replacement for the unavailable backend.
///
/// Response objects are freshly mapped on every request so optimistic changes
/// made by a widget cannot mutate the repository's source of truth.
class MockStoreRepository {
  MockStoreRepository._() {
    resetSessionState();
  }

  static final MockStoreRepository instance = MockStoreRepository._();

  final Set<String> _wishlistCodes = <String>{};
  final List<String> _cartCodes = <String>[];
  final List<DemoAddressData> _addresses = <DemoAddressData>[];
  final List<DemoOrderData> _orders = <DemoOrderData>[];
  int _nextAddressId = 1;
  int _nextOrderId = 1001;

  void resetSessionState() {
    _wishlistCodes
      ..clear()
      ..addAll(<String>{'DEMO-001', 'DEMO-005', 'DEMO-008'});
    _cartCodes
      ..clear()
      ..addAll(<String>['DEMO-002', 'DEMO-006']);
    _addresses
      ..clear()
      ..addAll(DummyData.addresses);
    _orders
      ..clear()
      ..addAll(DummyData.orders);
    _nextAddressId = _addresses.fold<int>(
          0,
          (largest, item) => item.id > largest ? item.id : largest,
        ) +
        1;
    _nextOrderId = _orders.fold<int>(
          1000,
          (largest, item) => item.id > largest ? item.id : largest,
        ) +
        1;
  }

  Future<void> _simulateDelay() => Future<void>.delayed(AppConfig.demoDelay);

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  DemoProductData? _findProduct(dynamic idOrCode) {
    final lookup = idOrCode?.toString() ?? '';
    for (final product in DummyData.products) {
      if (product.productCode == lookup || product.id.toString() == lookup) {
        return product;
      }
    }
    return null;
  }

  Map<String, dynamic> _pageEnvelope<T>({
    required List<T> allItems,
    required int requestedPage,
    required int requestedPageSize,
    required Map<String, dynamic> Function(T item) toJson,
  }) {
    final pageSize = requestedPageSize > 0 ? requestedPageSize : 10;
    final totalPages =
        allItems.isEmpty ? 1 : ((allItems.length + pageSize - 1) ~/ pageSize);
    final currentPage = requestedPage < 1
        ? 1
        : requestedPage > totalPages
            ? totalPages
            : requestedPage;
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize) > allItems.length
        ? allItems.length
        : start + pageSize;
    final pageItems =
        start >= allItems.length ? <T>[] : allItems.sublist(start, end);

    return <String, dynamic>{
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': allItems.length,
      'hasPrevious': currentPage > 1,
      'hasNext': currentPage < totalPages,
      'data': pageItems.map(toJson).toList(),
    };
  }

  Future<category.CategoryResponseModel> getCategories(
    dynamic pageNumber,
    dynamic pageSize,
  ) async {
    await _simulateDelay();
    final result = _pageEnvelope<DemoCategoryData>(
      allItems: DummyData.categories,
      requestedPage: _asInt(pageNumber, fallback: 1),
      requestedPageSize: _asInt(pageSize, fallback: 10),
      toJson: (item) => <String, dynamic>{
        'categoryId': item.id,
        'categoryName': item.name,
        'categoryImage': item.imageAsset,
      },
    );
    return category.categoryResponseModelFromJson(jsonEncode(_success(result)));
  }

  Future<product_list.ProductResponseModel> getProducts(
    dynamic pageNumber,
    dynamic pageSize,
    dynamic search,
    dynamic companyIds,
    dynamic maximumPrice,
    dynamic categoryId,
  ) async {
    await _simulateDelay();

    final query = search?.toString().trim().toLowerCase() ?? '';
    final selectedCompanyIds = companyIds
            ?.toString()
            .split(',')
            .map((value) => int.tryParse(value.trim()))
            .whereType<int>()
            .toSet() ??
        <int>{};
    final selectedCategoryId = _asInt(categoryId);
    final priceLimit = _asInt(maximumPrice, fallback: 10000);

    final filteredProducts = DummyData.products.where((product) {
      final searchableText = <String>[
        product.name,
        product.description,
        product.productCode,
        product.sku,
        product.brand,
        product.categoryName,
      ].join(' ').toLowerCase();
      final matchesSearch = query.isEmpty || searchableText.contains(query);
      final matchesCategory =
          selectedCategoryId == 0 || product.categoryId == selectedCategoryId;
      final matchesCompany = selectedCompanyIds.isEmpty ||
          selectedCompanyIds.contains(product.brandId);
      final matchesPrice = product.discountedPrice <= priceLimit;
      return product.isAvailable &&
          matchesSearch &&
          matchesCategory &&
          matchesCompany &&
          matchesPrice;
    }).toList();

    final products = _pageEnvelope<DemoProductData>(
      allItems: filteredProducts,
      requestedPage: _asInt(pageNumber, fallback: 1),
      requestedPageSize: _asInt(pageSize, fallback: 10),
      toJson: (product) => <String, dynamic>{
        'productId': product.id,
        'productName': product.name,
        'productImage': product.imageAsset,
        'productCode': product.productCode,
        'isInWishList': _wishlistCodes.contains(product.productCode),
      },
    );

    final companies = DummyData.products
        .map((product) => MapEntry(product.brandId, product.brand))
        .toSet()
        .map((entry) => <String, dynamic>{
              'id': entry.key,
              'name': entry.value,
            })
        .toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

    return product_list.productResponseModelFromJson(
      jsonEncode(
        _success(<String, dynamic>{
          'company': companies,
          'products': products,
        }),
      ),
    );
  }

  Future<product_details.ProductDetailsResponseModel> getProductDetails(
    dynamic idOrCode,
  ) async {
    await _simulateDelay();
    final product = _findProduct(idOrCode) ?? DummyData.products.first;
    final result = <String, dynamic>{
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageAsset,
      'description': product.description,
      'attributeName': 'Variant',
      'isCompany': true,
      'isAttribute': false,
      'productCode': product.productCode,
      'isAddToCart': _cartCodes.contains(product.productCode),
      'prices': <Map<String, dynamic>>[
        <String, dynamic>{
          'companyId': product.brandId,
          'attributeId': 0,
          'price': product.originalPrice,
          'discount': product.discountPercentage,
        },
      ],
      'company': <Map<String, dynamic>>[
        <String, dynamic>{'id': product.brandId, 'name': product.brand},
      ],
      'attributeValues': <Map<String, dynamic>>[],
    };
    return product_details.productDetailsResponseModelFromJson(
      jsonEncode(_success(result)),
    );
  }

  Future<cart.CartResponseModel> getCart() async {
    await _simulateDelay();
    final products = _cartCodes
        .map(_findProduct)
        .whereType<DemoProductData>()
        .map(_cartProductJson)
        .toList();
    return cart.cartResponseModelFromJson(jsonEncode(_success(products)));
  }

  Map<String, dynamic> _cartProductJson(DemoProductData product) =>
      <String, dynamic>{
        'cartId': 1000 + product.id,
        'productId': product.id,
        'productName': product.name,
        'productImage': product.imageAsset,
        'productCode': product.productCode,
        'attributeName': null,
        'isCompany': true,
        'isAttribute': false,
        'attributeId': 0,
        'prices': <Map<String, dynamic>>[
          <String, dynamic>{
            'companyId': product.brandId,
            'attributeId': 0,
            'price': product.originalPrice,
            'discount': product.discountPercentage,
          },
        ],
        'company': <Map<String, dynamic>>[
          <String, dynamic>{'id': product.brandId, 'name': product.brand},
        ],
        'attributeValues': <Map<String, dynamic>>[],
      };

  Future<add_cart.AddToCartResponseModel> addToCart(String productCode) async {
    await _simulateDelay();
    final product = _findProduct(productCode);
    final isValid = product != null && product.isAvailable;
    if (isValid && !_cartCodes.contains(productCode)) {
      _cartCodes.add(productCode);
    }
    return add_cart.addToCartResponseModelFromJson(
      jsonEncode(
        isValid
            ? _success(<String, dynamic>{'productCode': productCode})
            : _failure('Product not found.'),
      ),
    );
  }

  Future<delete_cart.DeleteCartResponseModel> deleteCartItem(
    int cartId,
  ) async {
    await _simulateDelay();
    final productId = cartId - 1000;
    _cartCodes.removeWhere((code) => _findProduct(code)?.id == productId);
    return delete_cart.deleteCartResponseModelFromJson(
      jsonEncode(_success(<String, dynamic>{'cartId': cartId})),
    );
  }

  Future<wishlist.WishlistResponseModel> getWishlist() async {
    await _simulateDelay();
    final products = _wishlistCodes
        .map(_findProduct)
        .whereType<DemoProductData>()
        .map(
          (product) => <String, dynamic>{
            'productId': product.id,
            'productName': product.name,
            'productDescription': product.description,
            'productImage': product.imageAsset,
            'productCode': product.productCode,
            'isAddedIntoCart': _cartCodes.contains(product.productCode),
          },
        )
        .toList();
    return wishlist.wishlistResponseModelFromJson(
      jsonEncode(_success(products)),
    );
  }

  Future<remove_wishlist.RemoveWishlistResponseModel> toggleWishlist(
    String productCode,
  ) async {
    await _simulateDelay();
    final product = _findProduct(productCode);
    if (product == null) {
      return remove_wishlist.removeWishlistResponseModelFromJson(
        jsonEncode(_failure('Product not found.')),
      );
    }
    if (!_wishlistCodes.remove(productCode)) {
      _wishlistCodes.add(productCode);
    }
    return remove_wishlist.removeWishlistResponseModelFromJson(
      jsonEncode(
        _success(<String, dynamic>{
          'productCode': productCode,
          'isInWishList': _wishlistCodes.contains(productCode),
        }),
      ),
    );
  }

  Future<address.AddressByUserIdResponseModel> getAddresses() async {
    await _simulateDelay();
    final result = _addresses
        .map((item) => <String, dynamic>{'id': item.id, 'name': item.name})
        .toList();
    return address.addressByUserIdResponseModelFromJson(
      jsonEncode(_success(result)),
    );
  }

  Future<add_cart.AddToCartResponseModel> addAddress(String value) async {
    await _simulateDelay();
    final normalizedAddress = value.trim();
    if (normalizedAddress.isEmpty) {
      return add_cart.addToCartResponseModelFromJson(
        jsonEncode(_failure('Address cannot be empty.')),
      );
    }
    final newAddress = DemoAddressData(
      id: _nextAddressId++,
      name: normalizedAddress,
    );
    _addresses.add(newAddress);
    return add_cart.addToCartResponseModelFromJson(
      jsonEncode(_success(<String, dynamic>{'id': newAddress.id})),
    );
  }

  Future<delete_cart.DeleteCartResponseModel> deleteAddress(int id) async {
    await _simulateDelay();
    _addresses.removeWhere((item) => item.id == id);
    return delete_cart.deleteCartResponseModelFromJson(
      jsonEncode(_success(<String, dynamic>{'id': id})),
    );
  }

  Future<user_details.UserDetailsResponseModel> getUserDetails() async {
    await _simulateDelay();
    return user_details.userDetailsResponseModelFromJson(
      jsonEncode(
        _success(<String, dynamic>{
          'userName': DummyData.user.name,
          'phoneNumber': DummyData.user.phone,
        }),
      ),
    );
  }

  Future<orders.OrdersResponseModel> getOrders() async {
    await _simulateDelay();
    final result = _orders.reversed
        .map(
          (order) => <String, dynamic>{
            'id': order.id,
            'orderTime': order.orderTime,
            'totalAmount': order.totalAmount,
          },
        )
        .toList();
    return orders.ordersResponseModelFromJson(jsonEncode(_success(result)));
  }

  Future<view_order.ViewOrderResponseModel> getOrderDetails(dynamic id) async {
    await _simulateDelay();
    final orderId = _asInt(id);
    final order = _orders.firstWhere(
      (item) => item.id == orderId,
      orElse: () => _orders.first,
    );
    final result = <String, dynamic>{
      'address': order.address,
      'orderItems': order.items
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'discount': item.discount,
              'productName': item.productName,
            },
          )
          .toList(),
    };
    return view_order.viewOrderResponseModelFromJson(
      jsonEncode(_success(result)),
    );
  }

  Future<place_order.PlaceOrderCartResponseModel> placeOrder(
    dynamic payload,
  ) async {
    await _simulateDelay();
    final map = payload is Map ? payload : <String, dynamic>{};
    final rawItems = map['orderDetails'];
    final items = <DemoOrderItemData>[];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        if (rawItem is! Map) continue;
        final productCode = rawItem['productCode']?.toString() ?? '';
        final product = _findProduct(productCode);
        if (product == null) continue;
        final requestedQuantity = _asInt(rawItem['qty'], fallback: 1);
        final quantity = requestedQuantity < 1
            ? 1
            : requestedQuantity > 99
                ? 99
                : requestedQuantity;
        items.add(
          DemoOrderItemData(
            id: product.id,
            productCode: product.productCode,
            productName: product.name,
            quantity: quantity,
            unitPrice: product.originalPrice,
            discount: product.discountPercentage,
          ),
        );
      }
    }
    if (items.isEmpty) {
      return place_order.placeOrderCartResponseModelFromJson(
        jsonEncode(_failure('No valid products were supplied.')),
      );
    }

    final requestedAddress = map['address']?.toString().trim() ?? '';
    final order = DemoOrderData(
      id: _nextOrderId++,
      orderTime: DateTime.now().toIso8601String(),
      address: requestedAddress.isEmpty
          ? (_addresses.isEmpty
              ? 'Demo delivery address'
              : _addresses.first.name)
          : requestedAddress,
      items: items,
    );
    _orders.add(order);
    _cartCodes.removeWhere(
      (code) => items.any((item) => item.productCode == code),
    );
    return place_order.placeOrderCartResponseModelFromJson(
      jsonEncode(_success(<String, dynamic>{'orderId': order.id})),
    );
  }

  Future<contact.ContactResponseModel> getContacts() async {
    await _simulateDelay();
    final page = _pageEnvelope<DemoBranchData>(
      allItems: DummyData.branches,
      requestedPage: 1,
      requestedPageSize: 50,
      toJson: (branch) => <String, dynamic>{
        'id': branch.id,
        'branchName': branch.name,
        'phoneNumber': branch.phone,
        'email': branch.email,
        'address': branch.address,
      },
    );
    return contact.contactResponseModelFromJson(jsonEncode(_success(page)));
  }

  Map<String, dynamic> _success(dynamic result) => <String, dynamic>{
        'statusCode': 200,
        'isSuccess': true,
        'errorMessages': <dynamic>[],
        'result': result,
      };

  Map<String, dynamic> _failure(String message) => <String, dynamic>{
        'statusCode': 400,
        'isSuccess': false,
        'errorMessages': <String>[message],
        'result': null,
      };
}
