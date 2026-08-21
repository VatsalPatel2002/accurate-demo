import 'package:get/get.dart';

import 'authentication_controller/login_controller.dart';
import 'dashboard/dashboard_controller.dart';

/// Owns controllers that are shared by every top-level route.
///
/// GetX otherwise associates a controller with whichever route first called
/// `Get.put`. Replacing that route can dispose the controller while the new
/// route is already using it. Keeping these two app-scoped prevents disposed
/// TextEditingControllers during navigation.
class AppControllers {
  const AppControllers._();

  static DashboardController get dashboard {
    if (Get.isRegistered<DashboardController>()) {
      return Get.find<DashboardController>();
    }
    return Get.put(DashboardController(), permanent: true);
  }

  static LoginController get login {
    dashboard;
    if (Get.isRegistered<LoginController>()) {
      return Get.find<LoginController>();
    }
    return Get.put(LoginController(), permanent: true);
  }

  static void initialize() {
    dashboard;
    login;
  }
}
