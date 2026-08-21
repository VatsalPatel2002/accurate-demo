import 'dart:developer';

import 'package:accurate/models/wishlist/wishlist_response_model.dart';
import 'package:get/get.dart';

import '../../routes/appRoutes.dart';
import '../../services/ApiServices.dart';

class WishListController extends GetxController {
  final RxList<Result> wishList = <Result>[].obs;
  var isLoading = false.obs;
  var isMutating = false.obs;
  var errorMessage = "".obs;

  Future<void> getWishList() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = "";
    try {
      final data = await RemoteService.getWishList();
      if (data != null && data.isSuccess == true) {
        wishList.assignAll(data.result);
      } else {
        errorMessage.value = "Unable to load the wishlist";
      }
    } catch (error) {
      errorMessage.value = "Unable to load the wishlist";
      log("Error fetching wishlist: $error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(String productCode) async {
    if (isMutating.value || productCode.trim().isEmpty) return;

    isMutating.value = true;
    errorMessage.value = "";
    try {
      final response = await RemoteService.removeFromWishlist(productCode);
      if (response != null && response.isSuccess == true) {
        await getWishList();
      } else {
        errorMessage.value = "Unable to update the wishlist";
      }
    } catch (error) {
      errorMessage.value = "Unable to update the wishlist";
      log("Error updating wishlist: $error");
    } finally {
      isMutating.value = false;
    }
  }

  Future<void> addToCart(String productCode) async {
    if (isMutating.value || productCode.trim().isEmpty) return;

    isMutating.value = true;
    errorMessage.value = "";
    try {
      final response = await RemoteService.addToCart(productCode);
      if (response != null && response.isSuccess == true) {
        Get.offNamed(RoutesManager.getMyCartRoute());
      } else {
        errorMessage.value = "Unable to add this product to the cart";
      }
    } catch (error) {
      errorMessage.value = "Unable to add this product to the cart";
      log("Error adding wishlist item to cart: $error");
    } finally {
      isMutating.value = false;
    }
  }
}
