import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/cart/cart_response_model.dart';
import '../../services/ApiServices.dart';

class MyCartController extends GetxController {
  static const int maxQuantity = 99;

  final RxList<ProductResult> cartList = <ProductResult>[].obs;

  final RxList<Price> pricesData = <Price>[].obs;
  double totalPrice = 0;
  var finalTotalPrice = "0.00".obs;
  final RxList<Map<String, dynamic>> countList = <Map<String, dynamic>>[].obs;
  final TextEditingController addressController = TextEditingController();
  final RxList<String> savedAddresses = <String>[].obs;
  final RxString selectedSavedAddress = ''.obs;
  final RxInt selectedAddressOption = 0.obs;
  var isLoading = false.obs;
  var isPlacingOrder = false.obs;
  var isPreparingCheckout = false.obs;
  var isFetchingAddresses = false.obs;
  var isDeleting = false.obs;
  var errorMessage = "".obs;

  Future<void> getCartList() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = "";
    try {
      final response = await RemoteService.getCart();
      if (response != null && response.isSuccess == true) {
        final previousQuantities = <String, int>{
          for (var index = 0;
              index < cartList.length && index < countList.length;
              index++)
            cartList[index].productCode: quantityAt(index),
        };
        final previousPrices = <String, Price>{
          for (var index = 0;
              index < cartList.length && index < pricesData.length;
              index++)
            cartList[index].productCode: pricesData[index],
        };
        final items = List<ProductResult>.from(response.result);
        final validItems =
            items.where((item) => item.prices.isNotEmpty).toList();

        cartList.assignAll(validItems);
        pricesData.assignAll(validItems.map((item) {
          final previous = previousPrices[item.productCode];
          if (previous != null) {
            for (final price in item.prices) {
              if (price.companyId == previous.companyId &&
                  price.attributeId == previous.attributeId) {
                return price;
              }
            }
          }
          return item.prices.first;
        }));
        countList.assignAll(
          validItems.map(
            (item) => <String, dynamic>{
              "qty": previousQuantities[item.productCode] ?? 1,
              "productCode": item.productCode,
            },
          ),
        );
        if (validItems.length != items.length) {
          errorMessage.value = "Some cart items have unavailable pricing";
        }
        totalPriceCalculate();
      } else {
        errorMessage.value = "Unable to load the cart";
      }
    } catch (error) {
      errorMessage.value = "Unable to load the cart";
      log("Error fetching cart: $error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> postOrder() async {
    if (isPlacingOrder.value) return false;
    if (pricesData.isEmpty ||
        pricesData.length != countList.length ||
        pricesData.length != cartList.length) {
      errorMessage.value = "Your cart has no orderable items";
      return false;
    }

    final address = (selectedAddressOption.value == 0
            ? addressController.text
            : selectedSavedAddress.value)
        .trim();
    if (address.isEmpty) {
      errorMessage.value = "Please select or enter an address";
      return false;
    }
    if (selectedAddressOption.value == 1 && !savedAddresses.contains(address)) {
      errorMessage.value = "Please select a valid saved address";
      return false;
    }

    isPlacingOrder.value = true;
    errorMessage.value = "";
    try {
      final orderDetails = <Map<String, dynamic>>[];
      for (var index = 0; index < pricesData.length; index++) {
        orderDetails.add({
          "companyId": pricesData[index].companyId,
          "attributeValueId": pricesData[index].attributeId,
          "qty": quantityAt(index),
          "productCode": cartList[index].productCode,
        });
      }

      final data = {"address": address, "orderDetails": orderDetails};
      final response = await RemoteService.postOrder(data);
      if (response != null && response.isSuccess == true) {
        await getCartList();
        return true;
      } else {
        errorMessage.value = "Unable to place order";
        return false;
      }
    } catch (error) {
      errorMessage.value = "Unable to place order";
      log("Error placing cart order: $error");
      return false;
    } finally {
      isPlacingOrder.value = false;
    }
  }

  Price? priceAt(int index) {
    if (index < 0 || index >= pricesData.length) return null;
    return pricesData[index];
  }

  int quantityAt(int index) {
    if (index < 0 || index >= countList.length) return 1;
    final quantity = countList[index]["qty"];
    if (quantity is num && quantity > 0) {
      return quantity.toInt().clamp(1, maxQuantity).toInt();
    }
    return 1;
  }

  void incrementQuantity(int index) {
    _setQuantity(index, quantityAt(index) + 1);
  }

  void decrementQuantity(int index) {
    _setQuantity(index, quantityAt(index) - 1);
  }

  void _setQuantity(int index, int quantity) {
    if (index < 0 || index >= countList.length) return;
    countList[index] = <String, dynamic>{
      ...countList[index],
      "qty": quantity.clamp(1, maxQuantity).toInt(),
    };
    totalPriceCalculate();
  }

  bool updateData(String identity, int? id, int index) {
    if (id == null ||
        (identity != "company" && identity != "attribute") ||
        index < 0 ||
        index >= cartList.length ||
        index >= pricesData.length) {
      return false;
    }

    final currentPrice = pricesData[index];
    final availablePrices = cartList[index].prices;
    var priceIndex = identity == "company"
        ? availablePrices.indexWhere(
            (price) =>
                price.companyId == id &&
                price.attributeId == currentPrice.attributeId,
          )
        : availablePrices.indexWhere(
            (price) =>
                price.attributeId == id &&
                price.companyId == currentPrice.companyId,
          );

    // Some backends do not provide every company/attribute combination.
    // Select the first valid price for the requested option instead of ever
    // indexing the list with -1.
    if (priceIndex < 0) {
      priceIndex = identity == "company"
          ? availablePrices.indexWhere((price) => price.companyId == id)
          : availablePrices.indexWhere((price) => price.attributeId == id);
    }
    if (priceIndex >= 0) {
      pricesData[index] = availablePrices[priceIndex];
      errorMessage.value = "";
      totalPriceCalculate();
      return true;
    } else {
      errorMessage.value = "Pricing is unavailable for this selection";
      return false;
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

  Future<bool> deleteCartItem(int cartId) async {
    if (isDeleting.value) return false;

    isDeleting.value = true;
    errorMessage.value = "";
    try {
      final response = await RemoteService.deleteToCart(cartId);
      if (response != null && response.isSuccess == true) {
        await getCartList();
        return true;
      } else {
        errorMessage.value = "Unable to remove this cart item";
      }
    } catch (error) {
      errorMessage.value = "Unable to remove this cart item";
      log("Error deleting cart item: $error");
    } finally {
      isDeleting.value = false;
    }
    return false;
  }

  void totalPriceCalculate() {
    totalPrice = 0;
    final itemCount = pricesData.length < countList.length
        ? pricesData.length
        : countList.length;
    for (int index = 0; index < itemCount; index++) {
      final priceInfo = pricesData[index];
      final int price = priceInfo.price;
      final int discount = priceInfo.discount;
      final int items = quantityAt(index);
      final double discountedPrice = price * (1 - discount / 100);

      totalPrice += discountedPrice * items;
    }
    finalTotalPrice.value = totalPrice.toStringAsFixed(2);
    log("totalPriceCalculate \$${finalTotalPrice.value}");
  }

  @override
  void onClose() {
    addressController.dispose();
    super.onClose();
  }
}
