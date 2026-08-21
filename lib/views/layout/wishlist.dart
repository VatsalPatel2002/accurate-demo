import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/authentication_controller/login_controller.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../../controllers/layout/wishlist_controller.dart';
import '../../routes/appRoutes.dart';
import '../../utils/sidebar.dart';

class WishList extends StatefulWidget {
  static const routeName = '/wishlist';

  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardController dashboardController = AppControllers.dashboard;
  final WishListController wishListController = Get.put(WishListController());
  final LoginController loginController = AppControllers.login;

  @override
  void initState() {
    super.initState();
    dashboardController.isLoggedIn();
    wishListController.getWishList();
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
          // Background Decoration
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
          SizedBox(
            height: screenHeight * 1,
            child: SingleChildScrollView(
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
                                        backgroundColor:
                                            const Color(0xFF034255),
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
                                                            color:
                                                                Colors.white),
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
                                                        loginController
                                                            .logout();
                                                      },
                                                      child: Text(
                                                        'Yes',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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
                  // Wishlist Items
                  Obx(() {
                    if (wishListController.isLoading.value) {
                      // Show Loader
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF034255),
                        ),
                      );
                    } else {
                      if (wishListController.wishList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Text("Your wishlist is empty."),
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04, vertical: 20),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: wishListController.wishList.length,
                            itemBuilder: (context, index) {
                              final product =
                                  wishListController.wishList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                elevation: 4,
                                child: SizedBox(
                                  height: 150, // Explicit height for the card
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Image
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: OfflineAwareImage(
                                          source: product.productImage,
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Text(
                                                product.productName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Description
                                            Expanded(
                                              child: product.productDescription
                                                      .isNotEmpty
                                                  ? Text(
                                                      product
                                                          .productDescription,
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    )
                                                  : const SizedBox(), // Placeholder for empty content
                                            ),
                                            // Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    wishListController
                                                        .removeFromWishlist(
                                                            product
                                                                .productCode);
                                                  },
                                                  icon: const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                product.isAddedIntoCart == false
                                                    ? ElevatedButton(
                                                        onPressed: () {
                                                          wishListController
                                                              .addToCart(product
                                                                  .productCode);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFF034255),
                                                        ),
                                                        child: const Text(
                                                          "Add to Cart",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                  width: 0,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    }
                  }),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.05,
            right: screenWidth * 0.04,
            child: FloatingActionButton(
              onPressed: () {
                Get.offNamed(RoutesManager.getMyCartRoute());
              },
              backgroundColor: const Color(0xFF034255),
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
