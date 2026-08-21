import 'package:accurate/data/local/dummy_data.dart';
import 'package:accurate/widgets/offline_aware_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class NewArrivalsCarousel extends StatefulWidget {
  const NewArrivalsCarousel({
    super.key,
    required this.banners,
    required this.onExplore,
  });

  final List<DemoBannerData> banners;
  final ValueChanged<DemoBannerData> onExplore;

  @override
  State<NewArrivalsCarousel> createState() => _NewArrivalsCarouselState();
}

class _NewArrivalsCarouselState extends State<NewArrivalsCarousel> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;
  bool _isAutoPlayPaused = false;

  @override
  void didUpdateWidget(covariant NewArrivalsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.banners.isEmpty) {
      _currentIndex = 0;
    } else if (_currentIndex >= widget.banners.length) {
      _currentIndex = widget.banners.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    final hasMultipleBanners = widget.banners.length > 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final layoutWidth = availableWidth.clamp(0.0, 1000.0).toDouble();
        final isCompact = layoutWidth < 600;
        final isNarrow = layoutWidth < 480;
        final viewportFraction = isCompact ? 0.92 : 0.86;
        final textScaler = MediaQuery.textScalerOf(context);
        final titleFontSize = isCompact ? 23.0 : 34.0;
        final subtitleFontSize = isCompact ? 13.0 : 16.0;

        double scaledExtra(double fontSize) =>
            (textScaler.scale(fontSize) - fontSize)
                .clamp(0.0, double.infinity)
                .toDouble();

        final scaledHeightAllowance = scaledExtra(titleFontSize) * 2 * 1.08 +
            scaledExtra(subtitleFontSize) * 2 * 1.3 +
            scaledExtra(11) +
            scaledExtra(14) +
            (isNarrow ? 8 : 0);
        final baseHeight = isNarrow
            ? (layoutWidth * 0.52 + 220).clamp(380.0, 470.0).toDouble()
            : (layoutWidth * viewportFraction * 9 / 16 + 16)
                .clamp(
                  isCompact ? 300.0 : 320.0,
                  isCompact ? 360.0 : 520.0,
                )
                .toDouble();

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: layoutWidth,
            child: Column(
              key: const Key('new-arrivals-section'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: const Text(
                                'New Arrivals',
                                style: TextStyle(
                                  color: Color(0xFF034255),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Fresh picks, just landed',
                              style: TextStyle(
                                color: Color(0xFF52707A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasMultipleBanners && !animationsDisabled)
                        IconButton.filledTonal(
                          key: const Key('new-arrivals-autoplay-toggle'),
                          onPressed: () {
                            setState(() {
                              _isAutoPlayPaused = !_isAutoPlayPaused;
                            });
                          },
                          tooltip: _isAutoPlayPaused
                              ? 'Play new arrivals'
                              : 'Pause new arrivals',
                          icon: Icon(
                            _isAutoPlayPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: widget.banners.length,
                  itemBuilder: (context, itemIndex, pageViewIndex) {
                    final banner = widget.banners[itemIndex];
                    return _NewArrivalCard(
                      key: ValueKey(banner.productCode),
                      banner: banner,
                      index: itemIndex,
                      total: widget.banners.length,
                      isCompact: isCompact,
                      isNarrow: isNarrow,
                      onExplore: () => widget.onExplore(banner),
                    );
                  },
                  options: CarouselOptions(
                    height: baseHeight + scaledHeightAllowance,
                    viewportFraction: viewportFraction,
                    enlargeCenterPage: hasMultipleBanners,
                    enlargeFactor: 0.08,
                    enableInfiniteScroll: hasMultipleBanners,
                    autoPlay: hasMultipleBanners &&
                        !_isAutoPlayPaused &&
                        !animationsDisabled,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 700),
                    autoPlayCurve: Curves.easeOutCubic,
                    pauseAutoPlayOnTouch: true,
                    pauseAutoPlayOnManualNavigate: true,
                    onPageChanged: (index, reason) {
                      if (mounted) {
                        setState(() => _currentIndex = index);
                      }
                    },
                  ),
                ),
                if (hasMultipleBanners) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.banners.length, (index) {
                      final isActive = index == _currentIndex;
                      void showPage() {
                        if (animationsDisabled) {
                          _carouselController.jumpToPage(index);
                          return;
                        }
                        _carouselController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                        );
                      }

                      return Semantics(
                        button: true,
                        selected: isActive,
                        label:
                            'Show new arrival ${index + 1} of ${widget.banners.length}',
                        onTap: showPage,
                        child: ExcludeSemantics(
                          child: InkWell(
                            key: Key('new-arrivals-indicator-$index'),
                            customBorder: const CircleBorder(),
                            onTap: showPage,
                            child: SizedBox.square(
                              dimension: 48,
                              child: Center(
                                child: AnimatedContainer(
                                  duration: animationsDisabled
                                      ? Duration.zero
                                      : const Duration(milliseconds: 250),
                                  width: isActive ? 28 : 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? const Color(0xFF034255)
                                        : const Color(0xFFB5CACD),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NewArrivalCard extends StatelessWidget {
  const _NewArrivalCard({
    super.key,
    required this.banner,
    required this.index,
    required this.total,
    required this.isCompact,
    required this.isNarrow,
    required this.onExplore,
  });

  final DemoBannerData banner;
  final int index;
  final int total;
  final bool isCompact;
  final bool isNarrow;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(isCompact ? 20 : 26);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33034255),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF031A29)),
            ExcludeSemantics(
              child: OfflineAwareImage(
                source: banner.imageAsset,
                width: double.infinity,
                height: double.infinity,
                fit: isNarrow ? BoxFit.fitWidth : BoxFit.cover,
                alignment: isNarrow ? Alignment.topCenter : Alignment.center,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: isNarrow
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00033344),
                          Color(0x33033344),
                          Color(0xE6033344),
                          Color(0xFF033344),
                        ],
                        stops: [0, 0.34, 0.62, 1],
                      )
                    : const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xF2033344),
                          Color(0xC9034255),
                          Color(0x33034255),
                          Color(0x00034255),
                        ],
                        stops: [0, 0.38, 0.72, 1],
                      ),
              ),
            ),
            Align(
              alignment: isNarrow ? Alignment.bottomLeft : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(isCompact ? 18 : 30),
                child: FractionallySizedBox(
                  widthFactor: isNarrow ? 1 : (isCompact ? 0.58 : 0.48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: 'New arrival, slide ${index + 1} of $total',
                        child: ExcludeSemantics(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF66DED0),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'NEW ARRIVAL',
                              style: TextStyle(
                                color: Color(0xFF033B4B),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 9 : 13),
                      Text(
                        banner.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 23 : 34,
                          height: 1.08,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: isCompact ? 7 : 10),
                      Text(
                        banner.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFE2F3F2),
                          fontSize: isCompact ? 13 : 16,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: isCompact ? 13 : 18),
                      Semantics(
                        label: 'Shop ${banner.title}',
                        button: true,
                        onTap: onExplore,
                        child: ExcludeSemantics(
                          child: FilledButton.icon(
                            key: Key('explore-${banner.productCode}'),
                            onPressed: onExplore,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              backgroundColor: const Color(0xFF66DED0),
                              foregroundColor: const Color(0xFF033B4B),
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 14 : 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Shop now',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
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
}
