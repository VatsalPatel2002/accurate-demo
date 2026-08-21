import 'dart:developer';

import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/authentication_controller/login_controller.dart';
import 'package:accurate/controllers/dashboard/dashboard_controller.dart';
import 'package:accurate/controllers/layout/product_controller.dart';
import 'package:accurate/models/product/product_response_model.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/utils/sidebar.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Product extends StatefulWidget {
  static const routeName = '/product';
  const Product({super.key});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final ProductController productController =
      Get.isRegistered<ProductController>()
          ? Get.find<ProductController>()
          : Get.put(ProductController());
  final LoginController loginController = AppControllers.login;
  final DashboardController dashboardController = AppControllers.dashboard;
  final arguments = Get.arguments as Map<String, dynamic>?;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productController.isLoggedIn();
    productController.categoryId = arguments?['categoryId'] ?? 0;
    productController.search.value = arguments?['search'] ?? "";
    productController.searchController.text = arguments?['search'] ?? "";
    productController.fetchProducts();
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
          SizedBox(
            height: screenHeight,
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
                              productController.isLogin.value == false
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
                      key: const Key('product-search'),
                      controller: productController.searchController,
                      onSubmitted: (value) {
                        productController.onSearch(value);
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

                  // Categories Section
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Product",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF034255),
                          ),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.filter_list, color: Color(0xFF034255)),
                          onPressed: () {
                            // Step 1: Update the selectedCompanies before showing the bottom sheet
                            setState(() {
                              productController.selectedCompanies =
                                  productController.tempSelectedCompanies;
                            });

                            // Step 2: Show the bottom sheet
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                // Temporary selection to handle changes within modal
                                Map<int, bool> tempSelectedCompanies = Map.from(
                                    productController.selectedCompanies);
                                double tempPrice = productController.price;

                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Buttons
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      tempSelectedCompanies
                                                          .clear(); // Clear only temp selection
                                                    });
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF034255),
                                                  ),
                                                  child: Text("Reset",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      productController
                                                              .selectedCompanies =
                                                          Map.from(
                                                              tempSelectedCompanies);
                                                      productController.price =
                                                          tempPrice;
                                                    });
                                                    String selectedIds =
                                                        productController
                                                            .selectedCompanies
                                                            .keys
                                                            .join(',');
                                                    productController
                                                        .onApplyCompany(
                                                            selectedIds,
                                                            productController
                                                                .price);
                                                    Navigator.pop(
                                                        context); // Close modal
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF034255),
                                                  ),
                                                  child: Text("Apply",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            // Slider
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text("Value"),
                                                Text(tempPrice
                                                    .toInt()
                                                    .toString()),
                                              ],
                                            ),
                                            Slider(
                                              value: tempPrice,
                                              min: 0,
                                              max: 10000,
                                              divisions: 100,
                                              activeColor: Color(0xFF034255),
                                              onChanged: (value) {
                                                setState(() {
                                                  tempPrice = value;
                                                });
                                              },
                                            ),
                                            // Company Filter
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Company",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            Expanded(
                                              child: GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 3.5,
                                                  crossAxisSpacing: 10.0,
                                                  mainAxisSpacing: 5.0,
                                                ),
                                                itemCount: productController
                                                    .filterCompany.length,
                                                itemBuilder: (context, index) {
                                                  final company =
                                                      productController
                                                          .filterCompany[index];
                                                  return CheckboxListTile(
                                                    title: Text(company.name),
                                                    value:
                                                        tempSelectedCompanies[
                                                                company.id] ??
                                                            false,
                                                    activeColor:
                                                        Color(0xFF034255),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          tempSelectedCompanies[
                                                                  company.id] =
                                                              true;
                                                        } else {
                                                          tempSelectedCompanies
                                                              .remove(
                                                                  company.id);
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ).then((_) {
                              // If the user exits without pressing "Apply", reset the selection
                              productController.selectedCompanies =
                                  Map.from(productController.selectedCompanies);
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Categories Grid
                  PaginatedProducts(products: productController.product),

                  // SizedBox(child: buildListViewOfCategories(productController.products)),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
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
class PaginatedProducts extends StatefulWidget {
  final List<Datum> products;

  const PaginatedProducts({super.key, required this.products});

  @override
  State<PaginatedProducts> createState() => _PaginatedProductsState();
}

class _PaginatedProductsState extends State<PaginatedProducts> {
  int currentPage = 0;
  final ProductController productController = Get.find<ProductController>();
  final DashboardController dashboardController = AppControllers.dashboard;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentItems = productController.product;
      final totalPages = productController.totalPages; // Total number of pages

      if (productController.isLoading.value) {
        // Show Loader
        return Center(
          child: CircularProgressIndicator(
            color: Color(0xFF034255),
          ),
        );
      } else {
        // Show the content
        return Column(
          children: [
            if (productController.product.isEmpty)
              SizedBox(
                child: Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            // GridView for products
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
                log("Favorite clicked for ${currentItems[index].isInWishList}");
                return GestureDetector(
                  onTap: () {
                    Get.offNamed(RoutesManager.getProductDetails(),
                        arguments: currentItems[index].productCode);
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Card Content
                        Column(
                          children: [
                            // Image in Category Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: OfflineAwareImage(
                                    source: currentItems[index].productImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                            // Category Name
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                currentItems[index].productName,
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

                        // Favorite Icon Positioned at the top-right
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final isLoggedIn =
                                  await dashboardController.isLoggedIn();
                              if (!mounted || !context.mounted) return;

                              if (isLoggedIn) {
                                setState(() {
                                  currentItems[index].isInWishList =
                                      !currentItems[index].isInWishList;
                                  productController.removeFromWishlist(
                                      currentItems[index].productCode);
                                });
                              } else {
                                showCustomPopup(context);
                              }
                            },
                            // onTap: () {
                            //   // Handle favorite action here
                            //   setState(() {
                            //     currentItems[index].isInWishList = !currentItems[index].isInWishList;
                            //     productController.removeFromWishlist(currentItems[index].productCode);
                            //   });
                            //   log("Favorite clicked for ${currentItems[index].isInWishList}");
                            // },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons
                                      .favorite, // Change to Icons.favorite if selected
                                  color:
                                      currentItems[index].isInWishList == true
                                          ? Colors.red
                                          : Colors.black,
                                ),
                              ),
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
                        productController.onChangePage(currentPage);
                      });
                    },
                  ),
                // Page Numbers
                for (int i = 0; i < totalPages.value; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        currentPage = i;
                        productController.onChangePage(currentPage);
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
                          color: currentPage == i ? Colors.white : Colors.black,
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
                        productController.onChangePage(currentPage);
                      });
                    },
                  ),
              ],
            ),
          ],
        );
      }
    });
  }

  void showCustomPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          title: Center(
            child: Text(
              "Welcome!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please log in or register to continue.",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.offNamed(RoutesManager.getLoginRoute());
                      // Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text("Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text("Registration",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
