import 'dart:math' as math;

import 'package:accurate/controllers/app_controllers.dart';
import 'package:accurate/controllers/dashboard/dashboard_controller.dart';
import 'package:accurate/models/dashboard/orders_response_model.dart' as order;
import 'package:accurate/models/dashboard/view_order_response_model.dart'
    as order_detail;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  static const _brandColor = Color(0xFF034255);

  final TextEditingController _addressController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final DashboardController dashboardController;
  String? _actionMessage;
  bool _actionSucceeded = false;

  @override
  void initState() {
    super.initState();
    dashboardController = AppControllers.dashboard;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) dashboardController.getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: math.min(screenWidth * .94, 420).toDouble(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: RefreshIndicator(
                color: _brandColor,
                onRefresh: dashboardController.getProfile,
                child: Obx(
                  () => ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    children: [
                      if (dashboardController.isProfileLoading.value)
                        const LinearProgressIndicator(color: _brandColor),
                      if (dashboardController.profileError.value.isNotEmpty)
                        _buildErrorCard(),
                      if (_actionMessage != null) _buildActionMessage(),
                      _buildProfileCard(),
                      const SizedBox(height: 22),
                      _sectionHeader(
                        icon: Icons.location_on_outlined,
                        title: 'Saved Addresses',
                      ),
                      const SizedBox(height: 8),
                      _buildAddressList(),
                      const SizedBox(height: 12),
                      _buildAddAddressForm(),
                      const SizedBox(height: 24),
                      _sectionHeader(
                        icon: Icons.receipt_long_outlined,
                        title: 'Your Orders',
                      ),
                      const SizedBox(height: 8),
                      _buildOrderList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE1F5F2),
            foregroundColor: _brandColor,
            child: Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              header: true,
              child: const Text(
                'My Profile',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close profile',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(child: Text(dashboardController.profileError.value)),
            TextButton(
              onPressed: dashboardController.isProfileLoading.value
                  ? null
                  : dashboardController.getProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final displayName = dashboardController.name.value.trim();
    final phone = dashboardController.phone.value.trim();
    return Card(
      elevation: 0,
      color: const Color(0xFFEAF8F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Profile Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _profileLine(
              Icons.badge_outlined,
              displayName.isEmpty ? 'Loading name…' : displayName,
            ),
            const SizedBox(height: 10),
            _profileLine(
              Icons.phone_outlined,
              phone.isEmpty ? 'Loading phone number…' : phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMessage() {
    return Card(
      color: _actionSucceeded ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          _actionSucceeded ? Icons.check_circle_outline : Icons.error_outline,
          color: _actionSucceeded ? Colors.green.shade700 : Colors.red.shade700,
        ),
        title: Text(_actionMessage!),
        trailing: IconButton(
          tooltip: 'Dismiss message',
          onPressed: () => setState(() => _actionMessage = null),
          icon: const Icon(Icons.close),
        ),
      ),
    );
  }

  Widget _profileLine(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _brandColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader({required IconData icon, required String title}) {
    return Semantics(
      header: true,
      child: Row(
        children: [
          Icon(icon, color: _brandColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    if (!dashboardController.isProfileLoading.value &&
        dashboardController.addresses.isEmpty) {
      return const _EmptyProfileState(
        icon: Icons.add_location_alt_outlined,
        message: 'No saved addresses yet.',
      );
    }

    return Column(
      children: dashboardController.addresses.map((savedAddress) {
        final isDeleting =
            dashboardController.deletingAddressId.value == savedAddress.id;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          color: Colors.grey.shade50,
          child: ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
            leading: const Icon(Icons.home_outlined, color: _brandColor),
            title: Text(savedAddress.name),
            trailing: isDeleting
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: 'Delete address',
                    onPressed: dashboardController.deletingAddressId.value == 0
                        ? () => _confirmDeleteAddress(
                              savedAddress.id,
                              savedAddress.name,
                            )
                        : null,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddAddressForm() {
    final isAdding = dashboardController.isAddingAddress.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _addressController,
          enabled: !isAdding,
          minLines: 1,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addAddress(),
          decoration: InputDecoration(
            labelText: 'New address',
            hintText: 'House, street, city and postcode',
            prefixIcon: const Icon(Icons.add_location_alt_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: isAdding ? null : _addAddress,
          style: FilledButton.styleFrom(
            backgroundColor: _brandColor,
            minimumSize: const Size.fromHeight(48),
          ),
          icon: isAdding
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.add),
          label: Text(isAdding ? 'Adding…' : 'Add Address'),
        ),
      ],
    );
  }

  Widget _buildOrderList() {
    if (!dashboardController.isProfileLoading.value &&
        dashboardController.orderList.isEmpty) {
      return const _EmptyProfileState(
        icon: Icons.shopping_bag_outlined,
        message: 'No orders placed yet.',
      );
    }

    return Column(
      children: dashboardController.orderList
          .map((item) => _buildOrderCard(item))
          .toList(),
    );
  }

  Widget _buildOrderCard(order.Result item) {
    final isLoading = dashboardController.loadingOrderId.value == item.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: dashboardController.loadingOrderId.value == 0
            ? () => _openOrder(item.id)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFEAF8F6),
                foregroundColor: _brandColor,
                child: Icon(Icons.receipt_long_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${item.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.orderTime),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₹${item.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: _brandColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right, color: _brandColor),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addAddress() async {
    final value = _addressController.text.trim();
    if (value.isEmpty) {
      _showMessage('Please enter a complete address.');
      return;
    }
    final added = await dashboardController.addAddress(value);
    if (!mounted) return;
    if (added) {
      _addressController.clear();
      FocusScope.of(context).unfocus();
      _showMessage('Address added successfully.', success: true);
    } else {
      _showMessage('Address could not be added. Please try again.');
    }
  }

  Future<void> _confirmDeleteAddress(int id, String address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Remove “$address” from your saved addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deleted = await dashboardController.deleteAddress(id);
    if (!mounted) return;
    _showMessage(
      deleted ? 'Address deleted.' : 'Address could not be deleted.',
      success: deleted,
    );
  }

  Future<void> _openOrder(int id) async {
    final details = await dashboardController.viewOrder(id);
    if (!mounted) return;
    if (details == null) {
      _showMessage('Order details could not be loaded.');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .88,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _OrderDetails(details: details),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;
    setState(() {
      _actionMessage = message;
      _actionSucceeded = success;
    });
  }

  String _formatDate(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${twoDigits(value.day)}/${twoDigits(value.month)}/${value.year}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({required this.details});

  static const _brandColor = Color(0xFF034255);
  final order_detail.Result details;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Order Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: const Color(0xFFEAF8F6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.local_shipping_outlined, color: _brandColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Shipping Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(details.address),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Semantics(
          header: true,
          child: const Text(
            'Items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        if (details.orderItems.isEmpty)
          const _EmptyProfileState(
            icon: Icons.inventory_2_outlined,
            message: 'No items are available for this order.',
          )
        else
          ...details.orderItems.map((item) {
            final discountedUnitPrice =
                (item.unitPrice * (1 - item.discount / 100)).round();
            final total = discountedUnitPrice * item.quantity;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _brandColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Quantity: ${item.quantity}'),
                    Text('Unit price: ₹${item.unitPrice.toStringAsFixed(2)}'),
                    Text('Discount: ${item.discount}%'),
                    const Divider(),
                    Text(
                      'Item total: ₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _EmptyProfileState extends StatelessWidget {
  const _EmptyProfileState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
