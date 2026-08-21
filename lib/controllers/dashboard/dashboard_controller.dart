import 'dart:developer';

import 'package:accurate/config/app_config.dart';
import 'package:accurate/models/dashboard/address_by_userId_response_model.dart'
    as address;
import 'package:accurate/models/dashboard/category_response_model.dart';
import 'package:accurate/models/dashboard/orders_response_model.dart' as order;
import 'package:accurate/models/dashboard/view_order_response_model.dart'
    as order_item;
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:accurate/services/demo_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  int currentPage = 1;
  int pageSize = 10;
  var categories = <Category>[].obs;
  var isLoading = false.obs;
  var page = 1.obs;
  var totalPages = 1.obs;
  final TextEditingController searchController = TextEditingController();
  RxString name = "".obs;
  RxString phone = "".obs;
  final RxList<address.Result> addresses = <address.Result>[].obs;
  final RxList<order.Result> orderList = <order.Result>[].obs;
  final orderItems = order_item.Result(address: '', orderItems: []).obs;
  final RxBool isProfileLoading = false.obs;
  final RxBool isAddingAddress = false.obs;
  final RxInt deletingAddressId = 0.obs;
  final RxInt loadingOrderId = 0.obs;
  final RxString profileError = ''.obs;

  Future<void> fetchCategories() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final data = await RemoteService.getCategory(currentPage, pageSize);
      if (data != null && data.isSuccess == true) {
        categories.value = data.result.data;
        totalPages.value = data.result.totalPages;
        log("categories length -------------------${categories.length}");
      }
    } catch (e) {
      log("Error fetching categories: $e");
    } finally {
      isLoading.value = false; // Stop the loader
    }
  }

  void onChangePage(cPage) {
    currentPage = cPage + 1;
    fetchCategories();
  }

  void onSearch(value) {
    log("Current TextField Value: $value");
    if (value == "") {
      log("Current TextField Value is empty: $value");
    } else {
      Get.offNamed(
        RoutesManager.getProductList(),
        arguments: {'search': value},
      );
    }
  }

  var isLogin = false.obs;

  Future<bool> isLoggedIn() async {
    try {
      final bool loginStatus;
      if (AppConfig.useOfflineMode) {
        loginStatus = await DemoAuthService.instance.hasActiveSession();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        loginStatus = prefs.getBool("loginData") ?? false;
      }
      isLogin.value = loginStatus;
      return loginStatus;
    } catch (error) {
      log('Unable to read login state: $error');
      isLogin.value = false;
      return false;
    }
  }

  Future<void> getProfile() async {
    if (isProfileLoading.value) return;
    isProfileLoading.value = true;
    profileError.value = '';
    try {
      final results = await Future.wait<bool>(<Future<bool>>[
        userDetails(),
        addressByUserId(),
        orders(),
      ]);
      if (results.any((succeeded) => !succeeded)) {
        profileError.value = 'Some profile information could not be loaded.';
      }
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> category() async {
    try {
      final response = await RemoteService.getCategory(currentPage, pageSize);
      log('Category request succeeded: ${response?.isSuccess == true}');
    } catch (error) {
      log('Unable to fetch categories: $error');
    }
  }

  Future<bool> orders() async {
    try {
      final response = await RemoteService.getOrders();
      if (response != null && response.isSuccess == true) {
        orderList.assignAll(response.result);
        return true;
      }
    } catch (error) {
      log('Unable to fetch orders: $error');
    }
    return false;
  }

  Future<order_item.Result?> viewOrder(int id) async {
    if (loadingOrderId.value != 0) return null;
    loadingOrderId.value = id;
    try {
      final response = await RemoteService.viewOrder(id);
      if (response != null && response.isSuccess == true) {
        orderItems.value = response.result;
        return response.result;
      }
    } catch (error) {
      log('Unable to fetch order $id: $error');
    } finally {
      loadingOrderId.value = 0;
    }
    return null;
  }

  Future<bool> addressByUserId() async {
    try {
      final response = await RemoteService.getAddressByUserId();
      if (response != null && response.isSuccess == true) {
        addresses.assignAll(response.result);
        return true;
      }
    } catch (error) {
      log('Unable to fetch addresses: $error');
    }
    return false;
  }

  Future<bool> userDetails() async {
    try {
      final response = await RemoteService.getUserDetails();
      if (response != null && response.isSuccess == true) {
        name.value = response.result.userName;
        phone.value = response.result.phoneNumber;
        return true;
      }
    } catch (error) {
      log('Unable to fetch user details: $error');
    }
    return false;
  }

  Future<bool> deleteAddress(int id) async {
    if (deletingAddressId.value != 0) return false;
    deletingAddressId.value = id;
    try {
      final response = await RemoteService.deleteFromAddress(id);
      if (response != null && response.isSuccess == true) {
        return addressByUserId();
      }
    } catch (error) {
      log('Unable to delete address $id: $error');
    } finally {
      deletingAddressId.value = 0;
    }
    return false;
  }

  Future<bool> addAddress(String newAddress) async {
    final trimmedAddress = newAddress.trim();
    if (trimmedAddress.isEmpty) {
      log('A blank address was not added.');
      return false;
    }
    if (isAddingAddress.value) return false;

    isAddingAddress.value = true;
    try {
      final response = await RemoteService.addToAddress(trimmedAddress);
      if (response != null && response.isSuccess == true) {
        return addressByUserId();
      }
    } catch (error) {
      log('Unable to add address: $error');
    } finally {
      isAddingAddress.value = false;
    }
    return false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
