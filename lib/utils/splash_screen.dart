import 'dart:async';
import 'dart:developer';
import 'package:accurate/routes/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () => navigateUser());
  }

  void navigateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('loginData');
    log("object----------------$check");
    if (!mounted) return;

    if (check == true) {
      Get.offNamed(RoutesManager.getDashboardRoute());
    } else {
      Get.offNamed(RoutesManager.getLoginRoute());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
