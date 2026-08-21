class DemoUser {
  final int id;
  final String name;
  final String email;
  final String username;
  final String role;
  final String phone;

  const DemoUser({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.phone,
  });
}

class DemoCategoryData {
  final int id;
  final String name;
  final String imageAsset;

  const DemoCategoryData({
    required this.id,
    required this.name,
    required this.imageAsset,
  });
}

class DemoBannerData {
  final String title;
  final String subtitle;
  final String imageAsset;
  final String productCode;

  const DemoBannerData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.productCode,
  });
}

class DemoProductData {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final String categoryName;
  final int originalPrice;
  final int discountPercentage;
  final double rating;
  final int reviewCount;
  final int stockQuantity;
  final String sku;
  final String brand;
  final int brandId;
  final String imageAsset;
  final bool isFeatured;
  final bool isAvailable;

  const DemoProductData({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.originalPrice,
    required this.discountPercentage,
    required this.rating,
    required this.reviewCount,
    required this.stockQuantity,
    required this.sku,
    required this.brand,
    required this.brandId,
    required this.imageAsset,
    required this.isFeatured,
    required this.isAvailable,
  });

  String get productCode => 'DEMO-${id.toString().padLeft(3, '0')}';

  int get discountedPrice =>
      (originalPrice * (100 - discountPercentage) / 100).round();
}

class DemoAddressData {
  final int id;
  final String name;

  const DemoAddressData({required this.id, required this.name});
}

class DemoOrderItemData {
  final int id;
  final String productCode;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int discount;

  const DemoOrderItemData({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });
}

class DemoOrderData {
  final int id;
  final String orderTime;
  final String address;
  final List<DemoOrderItemData> items;

  const DemoOrderData({
    required this.id,
    required this.orderTime,
    required this.address,
    required this.items,
  });

  int get totalAmount => items.fold<int>(
        0,
        (total, item) =>
            total +
            (item.unitPrice * (100 - item.discount) / 100).round() *
                item.quantity,
      );
}

class DemoBranchData {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;

  const DemoBranchData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });
}

class DummyData {
  const DummyData._();

  static const DemoUser user = DemoUser(
    id: 1,
    name: 'Demo Admin',
    email: 'admin@example.com',
    username: 'admin',
    role: 'Admin',
    phone: '9876543210',
  );

  static const List<DemoBannerData> banners = [
    DemoBannerData(
      title: 'Wireless Bluetooth Headphones',
      subtitle: 'Immersive sound, designed for all-day comfort.',
      imageAsset: 'assets/banners/new_arrivals_headphones.png',
      productCode: 'DEMO-001',
    ),
    DemoBannerData(
      title: 'Smart Fitness Watch',
      subtitle: 'Track every move with a smarter everyday companion.',
      imageAsset: 'assets/banners/new_arrivals_smartwatch.png',
      productCode: 'DEMO-002',
    ),
    DemoBannerData(
      title: 'Laptop Backpack',
      subtitle: 'Organised storage for work, travel and everything between.',
      imageAsset: 'assets/banners/new_arrivals_backpack.png',
      productCode: 'DEMO-005',
    ),
  ];

  static const List<DemoCategoryData> categories = [
    DemoCategoryData(
      id: 1,
      name: 'Audio',
      imageAsset: 'assets/categories/audio.png',
    ),
    DemoCategoryData(
      id: 2,
      name: 'Wearables',
      imageAsset: 'assets/categories/wearables.png',
    ),
    DemoCategoryData(
      id: 3,
      name: 'Fashion',
      imageAsset: 'assets/categories/fashion.png',
    ),
    DemoCategoryData(
      id: 4,
      name: 'Footwear',
      imageAsset: 'assets/categories/footwear.png',
    ),
    DemoCategoryData(
      id: 5,
      name: 'Bags',
      imageAsset: 'assets/categories/bags.png',
    ),
    DemoCategoryData(
      id: 6,
      name: 'Home & Kitchen',
      imageAsset: 'assets/categories/home_kitchen.png',
    ),
    DemoCategoryData(
      id: 7,
      name: 'Computer Accessories',
      imageAsset: 'assets/categories/computer_accessories.png',
    ),
    DemoCategoryData(
      id: 8,
      name: 'Beauty',
      imageAsset: 'assets/categories/beauty.png',
    ),
  ];

  static const List<DemoProductData> products = [
    DemoProductData(
      id: 1,
      name: 'Wireless Bluetooth Headphones',
      description:
          'Comfortable over-ear headphones with rich sound, active noise reduction and 30-hour battery life.',
      categoryId: 1,
      categoryName: 'Audio',
      originalPrice: 3499,
      discountPercentage: 20,
      rating: 4.6,
      reviewCount: 428,
      stockQuantity: 24,
      sku: 'AUD-WBH-001',
      brand: 'SoundWave',
      brandId: 1,
      imageAsset: 'assets/products/demo_001_wireless_bluetooth_headphones.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 2,
      name: 'Smart Fitness Watch',
      description:
          'Water-resistant fitness watch with heart-rate tracking, sleep insights and a bright AMOLED display.',
      categoryId: 2,
      categoryName: 'Wearables',
      originalPrice: 4999,
      discountPercentage: 15,
      rating: 4.4,
      reviewCount: 316,
      stockQuantity: 18,
      sku: 'WBL-SFW-002',
      brand: 'FitPulse',
      brandId: 2,
      imageAsset: 'assets/products/demo_002_smart_fitness_watch.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 3,
      name: 'Cotton Casual Shirt',
      description:
          'Breathable regular-fit cotton shirt with a soft finish for comfortable everyday wear.',
      categoryId: 3,
      categoryName: 'Fashion',
      originalPrice: 1499,
      discountPercentage: 25,
      rating: 4.2,
      reviewCount: 184,
      stockQuantity: 42,
      sku: 'FSN-CCS-003',
      brand: 'UrbanWeave',
      brandId: 3,
      imageAsset: 'assets/products/demo_003_cotton_casual_shirt.png',
      isFeatured: false,
      isAvailable: true,
    ),
    DemoProductData(
      id: 4,
      name: 'Running Shoes',
      description:
          'Lightweight running shoes with cushioned midsoles, breathable mesh and durable rubber grip.',
      categoryId: 4,
      categoryName: 'Footwear',
      originalPrice: 2999,
      discountPercentage: 18,
      rating: 4.5,
      reviewCount: 267,
      stockQuantity: 31,
      sku: 'FTW-RSH-004',
      brand: 'StridePro',
      brandId: 4,
      imageAsset: 'assets/products/demo_004_running_shoes.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 5,
      name: 'Laptop Backpack',
      description:
          'Water-resistant 25-litre backpack with a padded laptop sleeve, organiser pockets and airflow straps.',
      categoryId: 5,
      categoryName: 'Bags',
      originalPrice: 2199,
      discountPercentage: 22,
      rating: 4.7,
      reviewCount: 391,
      stockQuantity: 27,
      sku: 'BAG-LBP-005',
      brand: 'TrailPack',
      brandId: 5,
      imageAsset: 'assets/products/demo_005_laptop_backpack.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 6,
      name: 'Stainless Steel Water Bottle',
      description:
          'Leak-proof insulated steel bottle that keeps drinks cold for 24 hours or hot for 12 hours.',
      categoryId: 6,
      categoryName: 'Home & Kitchen',
      originalPrice: 999,
      discountPercentage: 10,
      rating: 4.6,
      reviewCount: 522,
      stockQuantity: 65,
      sku: 'HNK-SWB-006',
      brand: 'HydraSteel',
      brandId: 6,
      imageAsset: 'assets/products/demo_006_stainless_steel_water_bottle.png',
      isFeatured: false,
      isAvailable: true,
    ),
    DemoProductData(
      id: 7,
      name: 'Portable Bluetooth Speaker',
      description:
          'Compact splash-resistant speaker with punchy bass, hands-free calls and 12-hour playback.',
      categoryId: 1,
      categoryName: 'Audio',
      originalPrice: 2799,
      discountPercentage: 17,
      rating: 4.3,
      reviewCount: 245,
      stockQuantity: 22,
      sku: 'AUD-PBS-007',
      brand: 'BeatBox',
      brandId: 7,
      imageAsset: 'assets/products/demo_007_portable_bluetooth_speaker.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 8,
      name: 'Mechanical Keyboard',
      description:
          'Tactile mechanical keyboard with hot-swappable switches, white backlight and a compact layout.',
      categoryId: 7,
      categoryName: 'Computer Accessories',
      originalPrice: 4499,
      discountPercentage: 12,
      rating: 4.8,
      reviewCount: 198,
      stockQuantity: 16,
      sku: 'CMP-MKB-008',
      brand: 'KeyForge',
      brandId: 8,
      imageAsset: 'assets/products/demo_008_mechanical_keyboard.png',
      isFeatured: true,
      isAvailable: true,
    ),
    DemoProductData(
      id: 9,
      name: 'Skin Care Combo',
      description:
          'Gentle cleanser, vitamin serum and daily moisturiser set suitable for normal and combination skin.',
      categoryId: 8,
      categoryName: 'Beauty',
      originalPrice: 1899,
      discountPercentage: 30,
      rating: 4.4,
      reviewCount: 359,
      stockQuantity: 38,
      sku: 'BTY-SCC-009',
      brand: 'PureGlow',
      brandId: 9,
      imageAsset: 'assets/products/demo_009_skin_care_combo.png',
      isFeatured: false,
      isAvailable: true,
    ),
    DemoProductData(
      id: 10,
      name: 'Coffee Maker',
      description:
          'Compact drip coffee maker with reusable filter, anti-drip valve and a six-cup glass carafe.',
      categoryId: 6,
      categoryName: 'Home & Kitchen',
      originalPrice: 3999,
      discountPercentage: 14,
      rating: 4.5,
      reviewCount: 173,
      stockQuantity: 14,
      sku: 'HNK-CFM-010',
      brand: 'BrewCraft',
      brandId: 10,
      imageAsset: 'assets/products/demo_010_coffee_maker.png',
      isFeatured: true,
      isAvailable: true,
    ),
  ];

  static const List<DemoAddressData> addresses = [
    DemoAddressData(
      id: 1,
      name: '12 Demo Street, Navrangpura, Ahmedabad, Gujarat 380009',
    ),
    DemoAddressData(
      id: 2,
      name: '44 Market Road, Andheri East, Mumbai, Maharashtra 400069',
    ),
  ];

  static const List<DemoOrderData> orders = [
    DemoOrderData(
      id: 1001,
      orderTime: '2026-08-12T10:30:00.000',
      address: '12 Demo Street, Navrangpura, Ahmedabad, Gujarat 380009',
      items: [
        DemoOrderItemData(
          id: 1,
          productCode: 'DEMO-001',
          productName: 'Wireless Bluetooth Headphones',
          quantity: 1,
          unitPrice: 3499,
          discount: 20,
        ),
        DemoOrderItemData(
          id: 6,
          productCode: 'DEMO-006',
          productName: 'Stainless Steel Water Bottle',
          quantity: 2,
          unitPrice: 999,
          discount: 10,
        ),
      ],
    ),
    DemoOrderData(
      id: 1002,
      orderTime: '2026-08-18T16:15:00.000',
      address: '44 Market Road, Andheri East, Mumbai, Maharashtra 400069',
      items: [
        DemoOrderItemData(
          id: 5,
          productCode: 'DEMO-005',
          productName: 'Laptop Backpack',
          quantity: 1,
          unitPrice: 2199,
          discount: 22,
        ),
      ],
    ),
  ];

  static const List<DemoBranchData> branches = [
    DemoBranchData(
      id: 1,
      name: 'Accurate Demo - Ahmedabad',
      phone: '+91 98765 43210',
      email: 'ahmedabad@example.com',
      address: 'C.G. Road, Navrangpura, Ahmedabad, Gujarat 380009',
    ),
    DemoBranchData(
      id: 2,
      name: 'Accurate Demo - Mumbai',
      phone: '+91 98765 43211',
      email: 'mumbai@example.com',
      address: 'Andheri East, Mumbai, Maharashtra 400069',
    ),
    DemoBranchData(
      id: 3,
      name: 'Accurate Demo - Bengaluru',
      phone: '+91 98765 43212',
      email: 'bengaluru@example.com',
      address: 'Indiranagar, Bengaluru, Karnataka 560038',
    ),
  ];
}
