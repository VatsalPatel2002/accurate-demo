import 'dart:developer';
import 'package:accurate/config/app_config.dart';
import 'package:accurate/controllers/authentication_controller/login_controller.dart';
import 'package:accurate/models/authentication/login_response_model.dart';
import 'package:accurate/models/cart/add_to_cart_response_model.dart';
import 'package:accurate/models/cart/cart_response_model.dart';
import 'package:accurate/models/cart/delete_cart_response_model.dart';
import 'package:accurate/models/cart/place_order_cart_response_model.dart';
import 'package:accurate/models/contact_us/contact_response_model.dart';
import 'package:accurate/models/dashboard/address_by_userId_response_model.dart';
import 'package:accurate/models/dashboard/category_response_model.dart';
import 'package:accurate/models/dashboard/orders_response_model.dart';
import 'package:accurate/models/dashboard/user_details_response_model.dart';
import 'package:accurate/models/dashboard/view_order_response_model.dart';
import 'package:accurate/models/product/product_response_model.dart';
import 'package:accurate/models/product/product_details_response_model.dart';
import 'package:accurate/models/wishlist/remove_wishlist_response_model.dart';
import 'package:accurate/models/wishlist/wishlist_response_model.dart';
import 'package:accurate/repositories/mock_store_repository.dart';
import 'package:accurate/services/demo_auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'BaseUrl.dart';

class RemoteService {
  static Future<dynamic> fetchLoginUsers(String no, String password) async {
    if (AppConfig.useOfflineMode) {
      return DemoAuthService.instance.authenticate(no, password);
    }
    var url = Uri.parse('${BaseUrl.baseUrl}Auth/login');
    var body = {
      'phoneNumber': no,
      'password': password,
    };

    log("Submitting login request");

    // Making the POST request
    http.Response response = await http.post(
      url,
      body: json.encode(body), // The request body needs to be JSON-encoded
      headers: {
        "Content-Type": "application/json",
      },
      encoding: Encoding.getByName('utf-8'),
    );

    if (response.statusCode == 200) {
      String? id = response.headers['x-session-id']; // Nullable String
      if (id != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('x-session-id', id);
      } else {
        log("x-session-id not found in headers.");
      }
      return loginResponseModelFromJson(response.body);
    } else {
      return null;
    }
  }

  static Future<dynamic> getCategory(pageNumber, pageSize) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getCategories(pageNumber, pageSize);
    }
    var url = Uri.parse(
        '${BaseUrl.baseUrl}CategoryOpen?pageNum=$pageNumber&pageSize=$pageSize');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('x-session-id');
    var token = prefs.getString('loginToken');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] =
          sessionId; // Add the session ID only if it exists
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      if (sessionId == null) {
        String? id = response.headers['x-session-id']; // Nullable String
        if (id != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('x-session-id', id);
        } else {
          log("x-session-id not found in headers.");
        }
      }

      return categoryResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getOrders() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getOrders();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}Orders');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return ordersResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getAddressByUserId() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getAddresses();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}Address/getAddressByUserId');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return addressByUserIdResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getUserDetails() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getUserDetails();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}WishList/user-details');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return userDetailsResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getContact() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getContacts();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}Branch?pageNumber=1&pageSize=50');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return contactResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getCart() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getCart();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}cart');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return cartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getWishList() async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getWishlist();
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}WishList');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return wishlistResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> removeFromWishlist(String productCode) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.toggleWishlist(productCode);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}WishList');
    var body = productCode;

    log("Updating wishlist for product $body");

    // Making the POST request
    http.Response response = await http.post(
      url,
      body: json.encode(body), // The request body needs to be JSON-encoded
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body From removeFromWishlist: ${response.body}");

    if (response.statusCode == 200) {
      return removeWishlistResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getProductList(
      pageNum, pageSize, search, companyIds, price, categoryId) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getProducts(
        pageNum,
        pageSize,
        search,
        companyIds,
        price,
        categoryId,
      );
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');

    String baseUrl = '${BaseUrl.baseUrl}ProductOpen';
    Map<String, dynamic> queryParams = {
      'pageNum': pageNum,
      'pageSize': pageSize,
      'price': price,
    };

    if (categoryId != 0) {
      queryParams['categoryId'] = categoryId;
    }
    if (companyIds != "") {
      queryParams['companyIds'] = companyIds;
    }
    if (search != "") {
      queryParams['search'] = search;
    }

    var url = Uri.parse(baseUrl).replace(
        queryParameters:
            queryParams.map((key, value) => MapEntry(key, value.toString())));
    log("url is a:--> $url");

    // var url = Uri.parse('${BaseUrl.baseUrl}ProductOpen?pageNum=$pageNum&pageSize=$pageSize&companyIds=$companyIds&price=$price&categoryId=$categoryId');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return productResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> addToCart(String productCode) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.addToCart(productCode);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}cart');
    var body = productCode;

    log("Adding product $body to cart");

    // Making the POST request
    http.Response response = await http.post(
      url,
      body: json.encode(body), // The request body needs to be JSON-encoded
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body: ${response.body}");

    if (response.statusCode == 201) {
      return addToCartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> getProductDetails(id) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getProductDetails(id);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}ProductOpen/$id');

    http.Response response = await http.get(url, headers: headers);

    log("Response Body getProductDetails: ${response.body}");

    if (response.statusCode == 200) {
      return productDetailsResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteToCart(int cartId) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.deleteCartItem(cartId);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}cart/$cartId');

    // Making the POST request
    http.Response response = await http.delete(
      url,
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return deleteCartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("notDash");
    } else {
      return null;
    }
  }

  static Future<dynamic> postOrder(data) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.placeOrder(data);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}Orders');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response =
        await http.post(url, headers: headers, body: json.encode(data));

    log("Response Body from postOrder :----------------> ${response.body}");

    if (response.statusCode == 200) {
      return placeOrderCartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> viewOrder(var id) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.getOrderDetails(id);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    var url = Uri.parse('${BaseUrl.baseUrl}Orders/$id');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    http.Response response = await http.get(
      url,
      headers: headers,
      // encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body:----------------> ${response.body}");

    if (response.statusCode == 200) {
      return viewOrderResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> deleteFromAddress(int addId) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.deleteAddress(addId);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}Address/$addId');

    // Making the POST request
    http.Response response = await http.delete(
      url,
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return deleteCartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }

  static Future<dynamic> addToAddress(String address) async {
    if (AppConfig.useOfflineMode) {
      return MockStoreRepository.instance.addAddress(address);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('loginToken');
    String? sessionId = prefs.getString('x-session-id');

    Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    if (sessionId != null && sessionId.isNotEmpty) {
      headers["x-session-id"] = sessionId;
    }

    var url = Uri.parse('${BaseUrl.baseUrl}Address');
    var body = {"address": address};

    // Making the POST request
    http.Response response = await http.post(
      url,
      body: json.encode(body), // The request body needs to be JSON-encoded
      headers: headers,
      encoding: Encoding.getByName('utf-8'),
    );

    log("Response Body in add address: ${response.body}");

    if (response.statusCode == 200) {
      return addToCartResponseModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("loginData", false);
      LoginController.sessionTimeout("dash");
    } else {
      return null;
    }
  }
}
