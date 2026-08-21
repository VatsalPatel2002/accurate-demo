import 'dart:ui' as ui;

import 'package:accurate/data/local/dummy_data.dart';
import 'package:accurate/widgets/new_arrivals_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all product and banner images are distinct bundled assets', () async {
    expect(DummyData.products, hasLength(10));
    final productImagePaths = DummyData.products
        .map((product) => product.imageAsset)
        .toList(growable: false);

    expect(productImagePaths.toSet(), hasLength(productImagePaths.length));
    for (final imagePath in productImagePaths) {
      expect(imagePath, startsWith('assets/products/'));
      final asset = await rootBundle.load(imagePath);
      expect(
        asset.lengthInBytes,
        greaterThan(0),
        reason: '$imagePath should be bundled and non-empty',
      );
    }

    expect(DummyData.banners, hasLength(3));
    final bannerImagePaths = DummyData.banners
        .map((banner) => banner.imageAsset)
        .toList(growable: false);
    final bannerProductCodes = DummyData.banners
        .map((banner) => banner.productCode)
        .toList(growable: false);

    expect(bannerImagePaths.toSet(), hasLength(bannerImagePaths.length));
    expect(bannerProductCodes.toSet(), hasLength(bannerProductCodes.length));

    for (final banner in DummyData.banners) {
      expect(banner.imageAsset, startsWith('assets/banners/'));
      final asset = await rootBundle.load(banner.imageAsset);
      expect(
        asset.lengthInBytes,
        greaterThan(0),
        reason: '${banner.imageAsset} should be bundled and non-empty',
      );

      final matchingProducts = DummyData.products
          .where((product) => product.productCode == banner.productCode)
          .toList(growable: false);
      expect(
        matchingProducts,
        hasLength(1),
        reason: '${banner.productCode} should identify exactly one product',
      );
      expect(banner.title, matchingProducts.single.name);
    }
  });

  testWidgets('New Arrivals carousel works on a compact screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    DemoBannerData? exploredBanner;
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewArrivalsCarousel(
              banners: DummyData.banners,
              onExplore: (banner) => exploredBanner = banner,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New Arrivals'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('explore-DEMO-001')).first);
    await tester.pump();
    expect(exploredBanner, same(DummyData.banners.first));

    await tester.tap(find.byKey(const Key('new-arrivals-indicator-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final secondIndicator = tester.getSemantics(
      find.bySemanticsLabel('Show new arrival 2 of 3'),
    );
    expect(
      secondIndicator.flagsCollection.isSelected,
      ui.Tristate.isTrue,
    );
    expect(tester.takeException(), isNull);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('New Arrivals carousel supports enlarged text on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewArrivalsCarousel(
              banners: DummyData.banners,
              onExplore: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New Arrivals'), findsOneWidget);
    expect(find.text('Wireless Bluetooth Headphones'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
