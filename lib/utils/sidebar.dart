import 'package:accurate/routes/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  Widget buildListTile({
    required String title,
    required IconData icon,
    required Null Function() tapHandler,
    required Color? tileColor,
    required Color tileTextColor,
    required Color tileIconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        size: 26,
        color: tileIconColor,
      ),
      title: Text(
        title,
        style: TextStyle(color: tileTextColor),
      ),
      onTap: tapHandler,
      tileColor: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    void navigateTo(String route) {
      if (Get.currentRoute == route) {
        Navigator.of(context).pop();
        return;
      }
      Get.offAllNamed(route);
    }

    return Drawer(
      width: 250,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          Image.asset(
            'assets/logo.png',
            height: screenHeight * 0.1,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 20,
          ),
          buildListTile(
            title: 'Dashboard',
            icon: Icons.home,
            tapHandler: () {
              navigateTo(RoutesManager.getDashboardRoute());
            },
            tileColor: Get.currentRoute == RoutesManager.getDashboardRoute()
                ? Color(0xFF034255)
                : Colors.white,
            tileTextColor: Get.currentRoute == RoutesManager.getDashboardRoute()
                ? Colors.white
                : Color(0xFF034255),
            tileIconColor: Get.currentRoute == RoutesManager.getDashboardRoute()
                ? Colors.white
                : Color(0xFF034255),
          ),
          SizedBox(
            height: 10,
          ),
          buildListTile(
            title: 'My Cart',
            icon: Icons.shopping_cart,
            tapHandler: () {
              navigateTo(RoutesManager.getMyCartRoute());
            },
            tileColor: Get.currentRoute == RoutesManager.getMyCartRoute()
                ? Color(0xFF034255)
                : Colors.white,
            tileTextColor: Get.currentRoute == RoutesManager.getMyCartRoute()
                ? Colors.white
                : Color(0xFF034255),
            tileIconColor: Get.currentRoute == RoutesManager.getMyCartRoute()
                ? Colors.white
                : Color(0xFF034255),
          ),
          SizedBox(
            height: 10,
          ),
          buildListTile(
            title: 'Contact Us',
            icon: Icons.call,
            tapHandler: () {
              navigateTo(RoutesManager.getContactUs());
            },
            tileColor: Get.currentRoute == RoutesManager.getContactUs()
                ? Color(0xFF034255)
                : Colors.white,
            tileTextColor: Get.currentRoute == RoutesManager.getContactUs()
                ? Colors.white
                : Color(0xFF034255),
            tileIconColor: Get.currentRoute == RoutesManager.getContactUs()
                ? Colors.white
                : Color(0xFF034255),
          ),
          SizedBox(
            height: 10,
          ),
          buildListTile(
            title: 'About Us',
            icon: Icons.info,
            tapHandler: () {
              navigateTo(RoutesManager.getAboutUs());
            },
            tileColor: Get.currentRoute == RoutesManager.getAboutUs()
                ? Color(0xFF034255)
                : Colors.white,
            tileTextColor: Get.currentRoute == RoutesManager.getAboutUs()
                ? Colors.white
                : Color(0xFF034255),
            tileIconColor: Get.currentRoute == RoutesManager.getAboutUs()
                ? Colors.white
                : Color(0xFF034255),
          ),
        ],
      ),
    );
  }
}
