import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/authentication_controller/login_controller.dart';
import 'package:accurate/controllers/dashboard/dashboard_controller.dart';
import 'package:accurate/controllers/layout/product_details_controller.dart';
import 'package:accurate/models/product/product_details_response_model.dart';
import 'package:accurate/routes/appRoutes.dart';
import 'package:accurate/utils/sidebar.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetails extends StatefulWidget {
  static const routeName = '/product-details';
  const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ProductDetailsController productDetailsController =
      Get.isRegistered<ProductDetailsController>()
          ? Get.find<ProductDetailsController>()
          : Get.put(ProductDetailsController());
  final LoginController loginController = AppControllers.login;
  final DashboardController dashboardController = AppControllers.dashboard;
  final arguments = Get.arguments;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dashboardController.isLoggedIn();
    productDetailsController.fetchProductDetails(arguments?.toString() ?? '');
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
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: TextField(
                      key: const Key('product-details-search'),
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

                  Obx(() {
                    var productDetails =
                        productDetailsController.productDetails.value;

                    if (productDetails == null) {
                      if (!productDetailsController.isLoading.value) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              productDetailsController
                                      .errorMessage.value.isNotEmpty
                                  ? productDetailsController.errorMessage.value
                                  : 'Product details are unavailable',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF034255),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Center(
                              child: OfflineAwareImage(
                                source: productDetails.productImage,
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: 10),
                            // Product Name
                            Text(
                              productDetails.productName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            // User who added the product
                            Text(
                              productDetails.description,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            _buildPurchaseOptions(productDetails),
                            SizedBox(height: 20),
                            // Buttons
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: productDetails.isAddToCart ||
                                        productDetailsController
                                            .isAddingToCart.value
                                    ? null
                                    : productDetailsController.addToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF034255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: productDetailsController
                                        .isAddingToCart.value
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        productDetails.isAddToCart
                                            ? "Already in Cart"
                                            : "Add To Cart",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: productDetailsController
                                        .isPreparingCheckout.value
                                    ? null
                                    : () => _prepareCheckout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF034255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: productDetailsController
                                        .isPreparingCheckout.value
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Buy Now",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),

                  const SizedBox(height: 120),
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

  Widget _buildPurchaseOptions(Result product) {
    final price = productDetailsController.selectedPrice;
    if (price == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Pricing is unavailable for this product.'),
        ),
      );
    }

    final companies = <int, Company>{
      for (final company in product.company) company.id: company,
    };
    final attributes = <int, AttributeValue>{
      for (final attribute in product.attributeValues) attribute.id: attribute,
    };
    final selectedCompanyId =
        companies.containsKey(price.companyId) ? price.companyId : null;
    final selectedAttributeId = price.attributeId is int &&
            attributes.containsKey(price.attributeId as int)
        ? price.attributeId as int
        : null;
    final discountedPrice = price.price * (1 - price.discount / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '₹${discountedPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              '₹${price.price}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            if (price.discount > 0)
              Chip(
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.green,
                label: Text(
                  '${price.discount}% OFF',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        if (product.isCompany && companies.isNotEmpty) ...[
          const SizedBox(height: 15),
          DropdownButtonFormField2<int>(
            key: ValueKey(
              'detail-company-${product.productCode}-${price.companyId}',
            ),
            isExpanded: true,
            value: selectedCompanyId,
            decoration: _variantDecoration('Company'),
            dropdownStyleData: const DropdownStyleData(maxHeight: 240),
            items: companies.values
                .map(
                  (company) => DropdownMenuItem<int>(
                    value: company.id,
                    child: Text(
                      company.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) =>
                productDetailsController.updateData('company', id),
          ),
        ],
        if (product.isAttribute && attributes.isNotEmpty) ...[
          const SizedBox(height: 15),
          DropdownButtonFormField2<int>(
            key: ValueKey(
              'detail-attribute-${product.productCode}-${price.attributeId}',
            ),
            isExpanded: true,
            value: selectedAttributeId,
            decoration: _variantDecoration(
              product.attributeName?.toString().trim().isNotEmpty == true
                  ? product.attributeName.toString()
                  : 'Option',
            ),
            dropdownStyleData: const DropdownStyleData(maxHeight: 240),
            items: attributes.values
                .map(
                  (attribute) => DropdownMenuItem<int>(
                    value: attribute.id,
                    child: Text(
                      attribute.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) =>
                productDetailsController.updateData('attribute', id),
          ),
        ],
        if ((product.isCompany && companies.isEmpty) ||
            (product.isAttribute && attributes.isEmpty)) ...[
          const SizedBox(height: 12),
          const Text(
            'Some product options are currently unavailable.',
            style: TextStyle(color: Colors.orange),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              key: const ValueKey('detail-decrease-quantity'),
              tooltip: 'Decrease quantity',
              onPressed: productDetailsController.count.value > 1
                  ? productDetailsController.decrementQuantity
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Semantics(
              label: 'Quantity ${productDetailsController.count.value}',
              child: Text(
                productDetailsController.count.value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('detail-increase-quantity'),
              tooltip: 'Increase quantity',
              onPressed: productDetailsController.count.value <
                      ProductDetailsController.maxQuantity
                  ? productDetailsController.incrementQuantity
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (productDetailsController.errorMessage.value.isNotEmpty)
          Text(
            productDetailsController.errorMessage.value,
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  InputDecoration _variantDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF034255)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Future<void> _prepareCheckout(BuildContext pageContext) async {
    if (productDetailsController.isPreparingCheckout.value) return;
    productDetailsController.isPreparingCheckout.value = true;
    try {
      final isLoggedIn = await dashboardController.isLoggedIn();
      if (!mounted || !pageContext.mounted) return;

      if (!isLoggedIn) {
        showCustomPopup(pageContext);
        return;
      }

      productDetailsController.errorMessage.value = '';
      await productDetailsController.fetchSavedAddresses();
      if (!mounted || !pageContext.mounted) return;
      showConfirmOrderPopup(pageContext);
    } finally {
      productDetailsController.isPreparingCheckout.value = false;
    }
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

  void showConfirmOrderPopup(BuildContext context) {
    if (productDetailsController.savedAddresses.isEmpty) {
      productDetailsController.selectedAddressOption.value = 0;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Obx(() => Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.sizeOf(dialogContext).height * .9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Confirm Your Order",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Payment Method",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.check_circle,
                          color: Color(0xFF034255),
                        ),
                        title: Text("Cash On Delivery"),
                        subtitle: Text('Pay when your order arrives'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Address",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioGroup<int>(
                        groupValue: productDetailsController
                            .selectedAddressOption.value,
                        onChanged: (value) {
                          if (value != null) {
                            productDetailsController
                                .selectedAddressOption.value = value;
                          }
                        },
                        child: Column(
                          children: [
                            const RadioListTile<int>(
                              value: 0,
                              contentPadding: EdgeInsets.zero,
                              title: Text("Enter a new address"),
                            ),
                            if (productDetailsController
                                .savedAddresses.isNotEmpty)
                              const RadioListTile<int>(
                                value: 1,
                                contentPadding: EdgeInsets.zero,
                                title: Text("Use a saved address"),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.only(left: 12, bottom: 8),
                                child: Text(
                                  'No saved addresses yet. Enter a new address.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (productDetailsController
                              .selectedAddressOption.value ==
                          0)
                        TextField(
                          controller:
                              productDetailsController.addressController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "New Address*",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'detail-saved-address-${productDetailsController.selectedSavedAddress.value}',
                          ),
                          isExpanded: true,
                          initialValue: productDetailsController.savedAddresses
                                  .contains(productDetailsController
                                      .selectedSavedAddress.value)
                              ? productDetailsController
                                  .selectedSavedAddress.value
                              : null,
                          onChanged: (newValue) {
                            if (newValue != null) {
                              productDetailsController
                                  .selectedSavedAddress.value = newValue;
                            }
                          },
                          items: productDetailsController.savedAddresses
                              .map(
                                (address) => DropdownMenuItem<String>(
                                  value: address,
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: "Select Address",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFF034255),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (productDetailsController
                          .errorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            productDetailsController.errorMessage.value,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      OverflowBar(
                        alignment: MainAxisAlignment.end,
                        overflowAlignment: OverflowBarAlignment.end,
                        spacing: 10,
                        overflowSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed:
                                productDetailsController.isPlacingOrder.value
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: productDetailsController
                                    .isPlacingOrder.value
                                ? null
                                : () async {
                                    final wasPlaced =
                                        await productDetailsController
                                            .postOrder();
                                    if (!dialogContext.mounted || !wasPlaced) {
                                      return;
                                    }
                                    Navigator.of(dialogContext).pop();
                                    await dashboardController.orders();
                                    Get.snackbar(
                                      'Order Confirmation',
                                      'Your order has been successfully placed!',
                                      backgroundColor: const Color(0xFF034255),
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF034255),
                            ),
                            child: productDetailsController.isPlacingOrder.value
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Confirm Order",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}
