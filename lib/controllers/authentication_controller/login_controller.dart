import 'dart:developer';

import 'package:accurate/config/app_config.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/services/demo_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accurate/services/ApiServices.dart';
import 'package:get/get.dart';

import '../dashboard/dashboard_controller.dart';

class LoginController extends GetxController {
  var username = ''.obs;
  var password = ''.obs;
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final DashboardController dashboardController =
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController(), permanent: true);

  Future<void> login() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final users = AppConfig.useOfflineMode
          ? await DemoAuthService.instance.authenticate(
              username.value,
              password.value,
            )
          : await RemoteService.fetchLoginUsers(
              username.value,
              password.value,
            );

      if (users != null && users.isSuccess == true) {
        if (AppConfig.useOfflineMode) {
          await DemoAuthService.instance.persistSession();
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool("loginData", true);
          await prefs.setString("loginToken", users.result);
        }

        dashboardController.isLogin.value = true;
        Get.offAllNamed(RoutesManager.getDashboardRoute());
      } else {
        _showLoginError();
      }
    } catch (error) {
      log('Login failed: $error');
      _showLoginError();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (AppConfig.useOfflineMode) {
        await DemoAuthService.instance.clearSession();
      } else {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }
    } catch (error) {
      log('Logout failed: $error');
    } finally {
      dashboardController.isLogin.value = false;
      dashboardController.isLoading.value = false;
      username.value = '';
      password.value = '';
      Get.offAllNamed(RoutesManager.getLoginRoute());
    }
  }

  static Future<void> sessionTimeout(route) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    // if(route != "notDash"){
    //   Get.offNamed(RoutesManager.getDashboardRoute());
    // }
  }

  void _showLoginError() {
    errorMessage.value = 'Invalid username or password';
  }
}
