import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/authentication_controller/login_controller.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/appRoutes.dart';
import '../../utils/sidebar.dart';

class AboutUs extends StatefulWidget {
  static const routeName = '/aboutus';

  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
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
                            dashboardController.isLogin.value == true
                                ? Row(
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
                                  )
                                : ElevatedButton(
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
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.all(16.0), // Apply padding to all content
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            gradient: const LinearGradient(
                              colors: [Colors.cyan, Colors.teal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 4.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'ABOUT US',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // About Section
                      Container(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome To Accurate Hardware Supplies",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Divider(color: Colors.teal),
                            SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(text: "At "),
                                  TextSpan(
                                    text: "Accurate Hardware Supplies",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        ", we are your go-to destination for premium-quality hardware and plumbing essentials. For over a decade, we have proudly served homeowners, contractors, and businesses, providing reliable solutions for projects of every scale. Our mission is simple: to empower your creativity and craftsmanship with the best tools and materials available.",
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // What We Offer Section
                      Container(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "What We Offer",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Divider(color: Colors.teal),
                            SizedBox(height: 8),
                            Text(
                              "Our extensive catalog is thoughtfully curated to meet all your hardware needs. From top-of-the-line tools and building materials to plumbing fixtures, electrical supplies, and accessories, we have everything you need under one roof.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                offerTile("Plumbing Supplies",
                                    "Pipes, fittings, and faucets etc."),
                                offerTile("Tools",
                                    "Hand tools, power tools, and safety gear etc."),
                                offerTile("Building Materials",
                                    "Cement, timber, and adhesives etc."),
                                offerTile("Electrical",
                                    "Wires, switches, and fixtures etc."),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Statistics Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.teal.shade300],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            statisticTile("1,00,000+", "Happy Customers"),
                            SizedBox(height: 16),
                            statisticTile("5500+", "Products Offered"),
                            SizedBox(height: 16),
                            statisticTile("100+", "Company Collaborations"),
                            SizedBox(height: 16),
                            statisticTile("10+", "Years of Experience"),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Why Choose Us Section
                      Container(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Why Choose Us",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Divider(color: Colors.teal),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                offerTile("Top-Quality Products",
                                    "We partner with trusted manufacturers to ensure every product meets the highest standards of durability and performance."),
                                offerTile("Exceptional Customer Service",
                                    "Our team of experts is always on hand to provide professional advice and personalized support."),
                                offerTile("Affordable Pricing",
                                    "We offer competitive prices without compromising on quality."),
                                offerTile("Fast Delivery",
                                    "With our seamless online store and reliable shipping services, your hardware essentials are just a click away."),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Our Values & Vision Section
                      Container(
                        padding: EdgeInsets.all(16.0),
                        color: Colors.teal.shade50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Our Values & Vision",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Divider(color: Colors.teal),
                            SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: [
                                  TextSpan(text: "At "),
                                  TextSpan(
                                    text: "Accurate Hardware Supplies",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        ", we believe in creating value beyond products. Our business is built on the foundations of trust, innovation, and sustainability.",
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: 16),
                            Column(
                              children: [
                                offerTile("",
                                    "Support our customers with the tools and materials they need to succeed."),
                                offerTile("",
                                    "Foster eco-friendly practices by offering sustainable and energy-efficient products."),
                                offerTile("",
                                    "Build lasting relationships through honesty, transparency, and exceptional service.")
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Contact Section
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.teal],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Get In Touch',
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Divider(
                              color: Colors.white70,
                              thickness: 1.0,
                              endIndent: 100.0,
                              indent: 100.0,
                            ),
                            const SizedBox(height: 10.0),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.black87),
                                children: [
                                  TextSpan(
                                      text: 'Have questions? Contact us at '),
                                  TextSpan(
                                    text: '(123) 456-7890',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget offerTile(String title, String description) {
    return ListTile(
      leading: Icon(Icons.check_circle, color: Colors.teal),
      title: title.isNotEmpty
          ? Text(title, style: TextStyle(fontWeight: FontWeight.bold))
          : null, // Hide the title if it is empty
      subtitle: Text(
        description,
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget statisticTile(String number, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.yellow.shade700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
