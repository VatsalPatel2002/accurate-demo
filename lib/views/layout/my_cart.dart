import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/layout/my_cart_controller.dart';
import 'package:accurate/models/cart/cart_response_model.dart';
import 'package:accurate/utils/user_profile.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/authentication_controller/login_controller.dart';
import '../../controllers/dashboard/dashboard_controller.dart';
import '../../routes/appRoutes.dart';
import '../../utils/sidebar.dart';

class MyCart extends StatefulWidget {
  static const routeName = '/mycart';

  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final DashboardController dashboardController = AppControllers.dashboard;
  final LoginController loginController = AppControllers.login;
  final MyCartController cartController = Get.isRegistered<MyCartController>()
      ? Get.find<MyCartController>()
      : Get.put(MyCartController());

  @override
  void initState() {
    super.initState();
    dashboardController.isLoggedIn();
    cartController.getCartList();
    dashboardController.getProfile();
    // cartController.totalPriceCalculate(0);
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
                  Obx(() {
                    if (cartController.isLoading.value) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Color(0xFF034255),
                          ),
                        ),
                      );
                    }
                    if (cartController.cartList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            cartController.errorMessage.value.isNotEmpty
                                ? cartController.errorMessage.value
                                : "Your cart is empty.",
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (cartController.errorMessage.value.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  cartController.errorMessage.value,
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartController.cartList.length,
                              itemBuilder: (context, index) {
                                final product = cartController.cartList[index];
                                return _buildCartItem(product, index);
                              },
                            ),
                            Card(
                              elevation: 4, // Adds shadow to the card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners for the card
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Order Summary',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // Order items
                                    ...cartController.cartList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final item = entry.value;
                                      final selectedPrice =
                                          cartController.priceAt(index);
                                      if (selectedPrice == null) {
                                        return const SizedBox.shrink();
                                      }
                                      final qty =
                                          cartController.quantityAt(index);
                                      final price = selectedPrice.price *
                                          (1 - selectedPrice.discount / 100);

                                      return orderItemRow(
                                        title: "${item.productName} (x$qty)",
                                        price: (price * qty).toStringAsFixed(2),
                                      );
                                    }),

                                    const Divider(
                                        thickness: 1), // Divider for separation

                                    // Total Amount Row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: _buildTotalRow(),
                                    ),

                                    // Proceed to Checkout Button
                                    SizedBox(
                                      width: double
                                          .infinity, // Make button full width
                                      child: ElevatedButton(
                                        onPressed: cartController
                                                .isPreparingCheckout.value
                                            ? null
                                            : () => _prepareCheckout(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF034255),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                30), // Rounded corners
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15), // Button height
                                        ),
                                        child: cartController
                                                .isPreparingCheckout.value
                                            ? const SizedBox.square(
                                                dimension: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text(
                                                "Proceed to Checkout",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(ProductResult product, int index) {
    final price = cartController.priceAt(index);
    if (price == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Pricing is unavailable for this item'),
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
    final selectedAttributeId =
        price.attributeId != null && attributes.containsKey(price.attributeId)
            ? price.attributeId
            : null;
    final discountedPrice = price.price * (1 - price.discount / 100);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OfflineAwareImage(
            source: product.productImage,
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    product.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove ${product.productName}',
                  onPressed: cartController.isDeleting.value
                      ? null
                      : () => showDeleteConfirmation(product.cartId),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Wrap(
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
                      '${price.discount}% Off',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          if (product.isCompany && companies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: DropdownButtonFormField<int>(
                key: ValueKey(
                  'cart-company-${product.cartId}-${price.companyId}',
                ),
                initialValue: selectedCompanyId,
                isExpanded: true,
                decoration: _dropdownDecoration('Company'),
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
                onChanged: (value) => cartController.updateData(
                  'company',
                  value,
                  index,
                ),
              ),
            ),
          if (product.isAttribute && attributes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: DropdownButtonFormField<int>(
                key: ValueKey(
                  'cart-attribute-${product.cartId}-${price.attributeId}',
                ),
                initialValue: selectedAttributeId,
                isExpanded: true,
                decoration:
                    _dropdownDecoration(product.attributeName ?? 'Option'),
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
                onChanged: (value) => cartController.updateData(
                  'attribute',
                  value,
                  index,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              children: [
                IconButton(
                  key: ValueKey('cart-decrease-${product.productCode}'),
                  tooltip: 'Decrease quantity',
                  onPressed: cartController.quantityAt(index) > 1
                      ? () => cartController.decrementQuantity(index)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Semantics(
                  label: 'Quantity ${cartController.quantityAt(index)}',
                  child: Text(
                    cartController.quantityAt(index).toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  key: ValueKey('cart-increase-${product.productCode}'),
                  tooltip: 'Increase quantity',
                  onPressed: cartController.quantityAt(index) <
                          MyCartController.maxQuantity
                      ? () => cartController.incrementQuantity(index)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
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

  Padding orderItemRow({required String title, required String price}) {
    final useStackedLayout = MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(16) > 24;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: useStackedLayout
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 3),
                Text(
                  '₹$price',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹$price',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
    );
  }

  Widget _buildTotalRow() {
    const labelStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
    final useStackedLayout = MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(20) > 30;
    final amount = Text(
      '₹${cartController.finalTotalPrice.value}',
      textAlign: TextAlign.end,
      style: labelStyle,
    );
    if (useStackedLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Total', style: labelStyle),
          const SizedBox(height: 4),
          amount,
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total', style: labelStyle),
        const SizedBox(width: 12),
        Flexible(child: amount),
      ],
    );
  }

  Future<void> _prepareCheckout(BuildContext pageContext) async {
    if (cartController.isPreparingCheckout.value) return;
    cartController.isPreparingCheckout.value = true;
    try {
      final isLoggedIn = await dashboardController.isLoggedIn();
      if (!mounted || !pageContext.mounted) return;

      if (!isLoggedIn) {
        showCustomPopup(pageContext);
        return;
      }

      cartController.errorMessage.value = '';
      await cartController.fetchSavedAddresses();
      if (!mounted || !pageContext.mounted) return;
      showConfirmOrderPopup(pageContext);
    } finally {
      cartController.isPreparingCheckout.value = false;
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
                      // Navigate to registration
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
    if (cartController.savedAddresses.isEmpty) {
      cartController.selectedAddressOption.value = 0;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Obx(() => Column(
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
                        const SizedBox(height: 10),
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
                          groupValue:
                              cartController.selectedAddressOption.value,
                          onChanged: (value) {
                            if (value != null) {
                              cartController.selectedAddressOption.value =
                                  value;
                            }
                          },
                          child: Column(
                            children: [
                              const RadioListTile<int>(
                                value: 0,
                                contentPadding: EdgeInsets.zero,
                                title: Text("Enter a new address"),
                              ),
                              if (cartController.savedAddresses.isNotEmpty)
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
                        if (cartController.selectedAddressOption.value == 0)
                          TextField(
                            controller: cartController.addressController,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "New Address*",
                              border: OutlineInputBorder(),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              'cart-saved-address-${cartController.selectedSavedAddress.value}',
                            ),
                            isExpanded: true,
                            initialValue: cartController.savedAddresses
                                    .contains(cartController
                                        .selectedSavedAddress.value)
                                ? cartController.selectedSavedAddress.value
                                : null,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                cartController.selectedSavedAddress.value =
                                    newValue;
                              }
                            },
                            items: cartController.savedAddresses
                                .map((String address) {
                              return DropdownMenuItem<String>(
                                value: address,
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Select Address",
                            ),
                          ),
                        const SizedBox(height: 20),
                        if (cartController.errorMessage.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              cartController.errorMessage.value,
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
                              onPressed: cartController.isPlacingOrder.value
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
                              onPressed: cartController.isPlacingOrder.value
                                  ? null
                                  : () async {
                                      final wasPlaced =
                                          await cartController.postOrder();
                                      if (!dialogContext.mounted ||
                                          !wasPlaced) {
                                        return;
                                      }
                                      Navigator.of(dialogContext).pop();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Your order has been successfully placed!',
                                              ),
                                              backgroundColor:
                                                  Color(0xFF034255),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                      }
                                      await dashboardController.orders();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF034255),
                              ),
                              child: cartController.isPlacingOrder.value
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
                    )),
              ),
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation(int cartId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete Confirmation"),
          content: Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final deleted = await cartController.deleteCartItem(cartId);
                if (!mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        deleted
                            ? 'Item deleted successfully.'
                            : 'Unable to remove this cart item.',
                      ),
                      backgroundColor:
                          deleted ? Colors.green : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF034255),
              ),
              child: Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
