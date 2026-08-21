import 'dart:developer';

import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/authentication_controller/login_controller.dart';
import 'package:accurate/controllers/dashboard/dashboard_controller.dart';
import 'package:accurate/data/local/dummy_data.dart';
import 'package:accurate/models/dashboard/category_response_model.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/utils/sidebar.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/widgets/new_arrivals_carousel.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final DashboardController dashboardController = AppControllers.dashboard;
  final LoginController loginController = AppControllers.login;

  @override
  void initState() {
    log("init methos called on dashboard.");
    super.initState();
    Future.delayed(Duration.zero, () {
      dashboardController.isLoggedIn();
      dashboardController.fetchCategories();
      dashboardController.getProfile();
    });
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
                      // Login Button
                      Obx(
                        () => dashboardController.isLogin.value == false
                            ? ElevatedButton(
                                onPressed: () {
                                  Get.offNamed(RoutesManager.getLoginRoute());
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
                                      Get.offNamed(RoutesManager.getWishList());
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
                                            content:
                                                Text('Do you want to logout?'),
                                            actions: [
                                              TextButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF034255),
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
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF034255),
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
                    key: const Key('dashboard-search'),
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
                SizedBox(height: screenHeight * 0.02),

                NewArrivalsCarousel(
                  banners: DummyData.banners,
                  onExplore: (banner) {
                    Get.toNamed(
                      RoutesManager.getProductDetails(),
                      arguments: banner.productCode,
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),

                // Categories Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF034255),
                    ),
                  ),
                ),

                // Categories Grid
                PaginatedCategories(categories: dashboardController.categories),

                // SizedBox(child: buildListViewOfCategories(dashboardController.categories)),
                SizedBox(height: screenHeight * 0.02),
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

// Paginated Categories Grid (unchanged)
class PaginatedCategories extends StatefulWidget {
  final List<Category> categories;

  const PaginatedCategories({super.key, required this.categories});

  @override
  State<PaginatedCategories> createState() => _PaginatedCategoriesState();
}

class _PaginatedCategoriesState extends State<PaginatedCategories> {
  int currentPage = 0;
  final DashboardController dashboardController = AppControllers.dashboard;

  @override
  Widget build(BuildContext context) {
    final currentItems = dashboardController.categories;
    final totalPages = dashboardController.totalPages;
    return Obx(() => dashboardController.isLoading.value
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // GridView for categories
              GridView.builder(
                padding: const EdgeInsets.all(10),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentItems.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.offNamed(RoutesManager.getProductList(), arguments: {
                        'categoryId': currentItems[index].categoryId
                      });
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Image in Category Card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: OfflineAwareImage(
                                  source: currentItems[index].categoryImage,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          // Category Name
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              currentItems[index].categoryName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Pagination Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // "Previous" Icon Button
                  if (currentPage > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF66ded0),
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage--;
                          dashboardController.onChangePage(currentPage);
                        });
                      },
                    ),
                  // Page Numbers
                  for (int i = 0; i < totalPages.value; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentPage = i;
                          dashboardController.onChangePage(currentPage);
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: currentPage == i
                              ? Colors.teal.withValues(alpha: 0.5)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "${i + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                currentPage == i ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  // "Next" Icon Button
                  if (currentPage < totalPages.value - 1)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF66ded0),
                      ),
                      onPressed: () {
                        setState(() {
                          currentPage++;
                          dashboardController.onChangePage(currentPage);
                        });
                      },
                    ),
                ],
              ),
            ],
          ));
  }
}
