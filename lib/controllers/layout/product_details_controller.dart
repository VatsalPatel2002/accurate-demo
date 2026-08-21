import 'dart:developer';

import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../models/product/product_details_response_model.dart';

class ProductDetailsController extends GetxController {
  static const int maxQuantity = 99;

  var isLoading = false.obs;
  var isPlacingOrder = false.obs;
  var isAddingToCart = false.obs;
  var errorMessage = "".obs;
  final RxList<Price> pricesData = <Price>[].obs;
  Rx<Result?> productDetails = Rx<Result?>(null);
  var count = 1.obs;
  String? productCode;
  final TextEditingController addressController = TextEditingController();
  final RxList<String> savedAddresses = <String>[].obs;
  final RxInt selectedAddressOption = 0.obs;
  final RxString selectedSavedAddress = ''.obs;
  final RxBool isPreparingCheckout = false.obs;
  final RxBool isFetchingAddresses = false.obs;

  Future<void> fetchProductDetails(String id) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = "";
    productDetails.value = null;
    pricesData.clear();
    productCode = null;
    count.value = 1;
    try {
      if (id.trim().isEmpty) {
        errorMessage.value = "Product details are unavailable";
        return;
      }

      final data = await RemoteService.getProductDetails(id);
      if (data != null && data.isSuccess == true) {
        final Result details = data.result;
        if (details.prices.isEmpty) {
          errorMessage.value = "Product pricing is unavailable";
          return;
        }

        pricesData.add(details.prices.first);
        productCode = details.productCode;
        productDetails.value = details;
        log("Product details fetched successfully");
      } else {
        errorMessage.value = "Product details are unavailable";
      }
    } catch (error) {
      errorMessage.value = "Product details are unavailable";
      log("Error fetching product details: $error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> postOrder() async {
    if (isPlacingOrder.value) return false;

    final code = productCode;
    final selectedAddress = (selectedAddressOption.value == 0
            ? addressController.text
            : selectedSavedAddress.value)
        .trim();
    if (code == null || code.isEmpty || pricesData.isEmpty) {
      errorMessage.value = "Product pricing is unavailable";
      return false;
    }
    if (selectedAddress.isEmpty) {
      errorMessage.value = "Please select or enter an address";
      return false;
    }
    if (selectedAddressOption.value == 1 &&
        !savedAddresses.contains(selectedAddress)) {
      errorMessage.value = "Please select a valid saved address";
      return false;
    }

    isPlacingOrder.value = true;
    errorMessage.value = "";
    try {
      final selectedPrice = pricesData.first;
      final data = {
        "address": selectedAddress,
        "orderDetails": [
          {
            "companyId": selectedPrice.companyId,
            "attributeValueId": selectedPrice.attributeId,
            "qty": count.value,
            "productCode": code,
          },
        ],
      };
      final response = await RemoteService.postOrder(data);
      if (response == null || response.isSuccess != true) {
        errorMessage.value = "Unable to place order";
        return false;
      }
      return true;
    } catch (error) {
      errorMessage.value = "Unable to place order";
      log("Error placing order: $error");
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Future<bool> fetchSavedAddresses() async {
    if (isFetchingAddresses.value) return false;
    isFetchingAddresses.value = true;
    try {
      final data = await RemoteService.getAddressByUserId();
      if (data != null && data.isSuccess == true && data.result is List) {
        final List<dynamic> addressList = data.result;
        savedAddresses.assignAll(
          addressList
              .map((address) => address.name.toString().trim())
              .where((address) => address.isNotEmpty)
              .toSet(),
        );
        if (!savedAddresses.contains(selectedSavedAddress.value)) {
          selectedSavedAddress.value =
              savedAddresses.isEmpty ? '' : savedAddresses.first;
        }
        if (savedAddresses.isEmpty) selectedAddressOption.value = 0;
        return true;
      }
    } catch (error) {
      errorMessage.value = "Unable to load saved addresses";
      log("Error fetching saved addresses: $error");
    } finally {
      isFetchingAddresses.value = false;
    }
    savedAddresses.clear();
    selectedSavedAddress.value = '';
    selectedAddressOption.value = 0;
    return false;
  }

  Price? get selectedPrice => pricesData.isEmpty ? null : pricesData.first;

  void incrementQuantity() {
    count.value = (count.value + 1).clamp(1, maxQuantity).toInt();
  }

  void decrementQuantity() {
    count.value = (count.value - 1).clamp(1, maxQuantity).toInt();
  }

  bool updateData(String identity, int? id) {
    final details = productDetails.value;
    if (details == null ||
        details.prices.isEmpty ||
        pricesData.isEmpty ||
        id == null ||
        (identity != "company" && identity != "attribute")) {
      return false;
    }

    final currentPrice = pricesData.first;
    var index = identity == "company"
        ? details.prices.indexWhere(
            (price) =>
                price.companyId == id &&
                price.attributeId == currentPrice.attributeId,
          )
        : details.prices.indexWhere(
            (price) =>
                price.attributeId == id &&
                price.companyId == currentPrice.companyId,
          );
    if (index < 0) {
      index = identity == "company"
          ? details.prices.indexWhere((price) => price.companyId == id)
          : details.prices.indexWhere((price) => price.attributeId == id);
    }
    if (index >= 0) {
      pricesData[0] = details.prices[index];
      errorMessage.value = "";
      return true;
    } else {
      errorMessage.value = "Pricing is unavailable for this selection";
      return false;
    }
  }

  Future<void> addToCart() async {
    if (isAddingToCart.value) return;

    final code = productCode;
    if (code == null || code.isEmpty) {
      errorMessage.value = "Product details are unavailable";
      return;
    }

    isAddingToCart.value = true;
    errorMessage.value = "";
    try {
      final response = await RemoteService.addToCart(code);
      if (response != null && response.isSuccess == true) {
        Get.offNamed(RoutesManager.getMyCartRoute());
      } else {
        errorMessage.value = "Unable to add this product to the cart";
      }
    } catch (error) {
      errorMessage.value = "Unable to add this product to the cart";
      log("Error adding product to cart: $error");
    } finally {
      isAddingToCart.value = false;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }
}
