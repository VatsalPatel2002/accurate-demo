import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: GetMaterialApp(
        title: 'Accurate',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        defaultTransition: Transition.noTransition,
        initialBinding: BindingsBuilder(AppControllers.initialize),
        initialRoute: RoutesManager.getSplashRoute(),
        getPages: RoutesManager.appRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
