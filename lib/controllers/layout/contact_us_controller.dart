import 'dart:developer';

import 'package:accurate/models/contact_us/contact_response_model.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ContactUsController extends GetxController {

  @override
  Future<void> onInit() async {
    super.onInit();
    contact();
  }

  var isLoading = true.obs;
  var branches = <Datum>[].obs;

  void contact() async {

    try {
      isLoading(true);
      var res = await RemoteService.getContact();
      if (res.isSuccess) {
        branches.value = res.result.data;
        log("message:------------------------------------> ${res.isSuccess}");
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch branches",
          backgroundColor: Colors.red, // Set background color to red for errors
          snackPosition: SnackPosition.BOTTOM, // Position at the bottom of the screen
          duration: Duration(seconds: 3), // Show for 3 seconds
          icon: Icon(Icons.error, color: Colors.white), // Use an error icon
          colorText: Colors.white, // White text for contrast
          margin: EdgeInsets.all(10), // Add margin around the snack bar
          borderRadius: 10, // Rounded corners
          boxShadows: [
            BoxShadow(
              color: Colors.black..withValues(alpha: 0.3), // Subtle shadow
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        );

      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch branches",
        backgroundColor: Colors.red, // Set background color to red for errors
        snackPosition: SnackPosition.BOTTOM, // Position at the bottom of the screen
        duration: Duration(seconds: 3), // Show for 3 seconds
        icon: Icon(Icons.error, color: Colors.white), // Use an error icon
        colorText: Colors.white, // White text for contrast
        margin: EdgeInsets.all(10), // Add margin around the snack bar
        borderRadius: 10, // Rounded corners
        boxShadows: [
          BoxShadow(
            color: Colors.black..withValues(alpha: 0.3), // Subtle shadow
            blurRadius: 5,
            offset: Offset(0, 3), // Shadow position
          ),
        ],
      );
    } finally {
      isLoading(false);
    }
  }
}