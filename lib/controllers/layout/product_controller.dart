import 'dart:developer';

import 'package:accurate/config/app_config.dart';
import 'package:accurate/models/product/product_response_model.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:accurate/services/demo_auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductController extends GetxController {
  var product = <Datum>[].obs;
  var filterCompany = <Company>[].obs;
  int currentPage = 1;
  int pageSize = 10;
  var isLoading = false.obs;
  var page = 1.obs;
  var totalPages = 1.obs;
  double price = 10000;
  Map<int, bool> selectedCompanies = {};
  Map<int, bool> tempSelectedCompanies = {};
  var categoryId = 0;
  var companyIds = "".obs;
  var search = "".obs;
  var errorMessage = "".obs;
  final TextEditingController searchController = TextEditingController();
  bool _fetchPending = false;

  Future<void> fetchProducts() async {
    if (isLoading.value) {
      _fetchPending = true;
      return;
    }

    isLoading.value = true;
    try {
      do {
        _fetchPending = false;
        try {
          final data = await RemoteService.getProductList(
            currentPage,
            pageSize,
            search.value,
            companyIds.value,
            price.toInt(),
            categoryId,
          );
          if (data != null && data.isSuccess == true) {
            product.assignAll(data.result.products.data);
            totalPages.value = data.result.products.totalPages;
            filterCompany.assignAll(data.result.company);
            errorMessage.value = "";
            log("products length: ${data.result.products.data.length}");
          } else {
            errorMessage.value = "Unable to load products";
          }
        } catch (error) {
          errorMessage.value = "Unable to load products";
          log("Error fetching products: $error");
        }
      } while (_fetchPending);
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(value) {
    currentPage = 1;
    search.value = value.toString();
    log("Current TextField Value: ${search.value}");
    fetchProducts();
  }

  void onChangePage(cPage) {
    currentPage = cPage + 1;
    fetchProducts();
  }

  void onApplyCompany(ids, sliderValue) {
    currentPage = 1;
    tempSelectedCompanies = Map<int, bool>.from(selectedCompanies);
    companyIds.value = ids.toString();
    price = (sliderValue as num).toDouble();
    fetchProducts();
  }

  void onReset() {
    currentPage = 1;
    selectedCompanies.clear();
    tempSelectedCompanies.clear();
    price = 10000;
    companyIds.value = "";
    fetchProducts();
  }

  Future<void> removeFromWishlist(String productCode) async {
    if (productCode.trim().isEmpty) return;
    try {
      final response = await RemoteService.removeFromWishlist(productCode);
      if (response != null && response.isSuccess == true) {
        await fetchProducts();
      }
    } catch (error) {
      log("Error updating wishlist: $error");
    }
  }

  var isLogin = false.obs;

  Future<void> isLoggedIn() async {
    try {
      if (AppConfig.useOfflineMode) {
        isLogin.value = await DemoAuthService.instance.hasActiveSession();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        isLogin.value = prefs.getBool("loginData") ?? false;
      }
    } catch (error) {
      log('Unable to read login state: $error');
      isLogin.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
