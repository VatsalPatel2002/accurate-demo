import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/layout/contact_us_controller.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/authentication_controller/login_controller.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/appRoutes.dart';
import '../../utils/sidebar.dart';

class ContactUs extends StatefulWidget {
  static const routeName = '/contactus';

  const ContactUs({super.key});
  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final contactUsController = Get.put(ContactUsController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardController dashboardController = AppControllers.dashboard;
  final LoginController loginController = AppControllers.login;

  @override
  void initState() {
    super.initState();
    dashboardController.isLoggedIn();
    dashboardController.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      endDrawer: UserProfile(),
      body: Stack(
        children: [
          Positioned(
            right: -screenWidth * 1.1,
            top: -screenHeight * 0.6,
            child: Container(
              width: screenWidth * 1.9,
              height: screenHeight * 1.4,
              decoration: const BoxDecoration(
                color: Color(0xFFb2ebe3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar and Login Button
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Company Logo
                      Image.asset(
                        'assets/logo.png',
                        height: screenHeight * 0.05,
                        fit: BoxFit.contain,
                      ),
                      Obx(
                        () => // Login Button
                            dashboardController.isLogin.value == false
                                ? ElevatedButton(
                                    onPressed: () {
                                      Get.offNamed(
                                          RoutesManager.getLoginRoute());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF034255),
                                    ),
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Get.offNamed(
                                              RoutesManager.getWishList());
                                        },
                                        icon: Icon(
                                          Icons.favorite,
                                          color: Color(0xFF034255),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Logout'),
                                                content: Text(
                                                    'Do you want to logout?'),
                                                actions: [
                                                  TextButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF034255),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: Text(
                                                      'No',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF034255),
                                                    ),
                                                    onPressed: () {
                                                      loginController.logout();
                                                    },
                                                    child: Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(
                                          Icons.logout,
                                          color: Color(0xFF034255),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _scaffoldKey.currentState
                                              ?.openEndDrawer();
                                        },
                                        icon: Icon(
                                          Icons.person,
                                          color: Color(0xFF034255),
                                        ),
                                      )
                                    ],
                                  ),
                      )
                    ],
                  ),
                ),
                // Search Field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: TextField(
                    controller: dashboardController.searchController,
                    onSubmitted: (value) {
                      dashboardController.onSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          // Open the drawer when the icon is pressed
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color(0xFF034255),
                            width: 2), // Focused border color
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.03, // 3% padding on the sides
                    screenHeight * 0.03, // Adjusted top padding
                    screenWidth * 0.03,
                    screenHeight * 0.02, // 2% bottom padding
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center-align content
                    children: [
                      const Text(
                        "Contact Us",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24, // Static font size
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF034255),
                        ),
                      ),
                      SizedBox(
                          height: screenHeight * 0.01), // 1% vertical spacing
                      const Text(
                        "\"WE'RE JUST A CALL AWAY – LET'S CONNECT AND BUILD TOGETHER!\"",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF034255),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Wrap the ListView in a container with a fixed height
                      SizedBox(
                        height: screenHeight * 0.7, // Set a height limit
                        child: Obx(() {
                          if (contactUsController.isLoading.value) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (contactUsController.branches.isEmpty) {
                            return const Center(
                              child: SizedBox(
                                height: 8, // Set the width to 800
                                child: Text(
                                  "No branches available.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF034255),
                                  ),
                                  textAlign: TextAlign
                                      .center, // Center the text inside the SizedBox
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: contactUsController.branches.length,
                            itemBuilder: (context, index) {
                              final branch =
                                  contactUsController.branches[index];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      screenHeight * 0.01, // 1% vertical margin
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(
                                        16), // Top-right rounded corner
                                    bottomRight: Radius.circular(
                                        16), // Bottom-right rounded corner
                                  ),
                                ),
                                elevation:
                                    2, // Reduced elevation to match the soft shadow
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.teal,
                                        width:
                                            4, // Left border with 2px thickness
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(
                                      screenWidth * 0.05), // Adjusted padding
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        branch.branchName,
                                        style: TextStyle(
                                          fontSize: screenWidth *
                                              0.05, // Dynamic font size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.01), // 1% vertical spacing
                                      Text(
                                        "Address: ${branch.address}",
                                        style: TextStyle(
                                          fontSize: screenWidth *
                                              0.04, // Dynamic font size
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.005), // Reduced spacing
                                      Text(
                                        "Phone: ${branch.phoneNumber}",
                                        style: TextStyle(
                                          fontSize: screenWidth *
                                              0.04, // Dynamic font size
                                        ),
                                      ),
                                      SizedBox(
                                          height: screenHeight *
                                              0.005), // Reduced spacing
                                      Text(
                                        "Email: ${branch.email}",
                                        style: TextStyle(
                                          fontSize: screenWidth *
                                              0.04, // Dynamic font size
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05, // Distance from the bottom
            right: screenWidth * 0.04, // Distance from the right
            child: FloatingActionButton(
              onPressed: () {
                Get.offNamed(RoutesManager.getMyCartRoute());
              },
              backgroundColor: const Color(0xFF034255), // Customize as needed
              child: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
