import 'package:accurate/config/app_config.dart';
import 'package:flutter/material.dart';

/// Displays local demo assets without ever touching the network in offline mode.
///
/// In live mode, absolute URLs are used as-is and legacy relative image paths
/// are resolved against [AppConfig.legacyImageBaseUrl].
class OfflineAwareImage extends StatelessWidget {
  const OfflineAwareImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final normalizedSource = source.trim();

    if (_isAsset(normalizedSource)) {
      return _buildAsset(normalizedSource);
    }

    if (AppConfig.useOfflineMode) {
      return _buildFallback();
    }

    if (normalizedSource.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      _resolveNetworkUrl(normalizedSource),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildAsset(String assetPath) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, __, ___) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return SizedBox(
      width: width,
      height: height,
      child: ColoredBox(
        color: Colors.black12,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.black45,
          ),
        ),
      ),
    );
  }

  bool _isAsset(String value) => value.startsWith('assets/');

  String _resolveNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return value;
    }

    final relativePath = value.startsWith('/') ? value : '/$value';
    return '${AppConfig.legacyImageBaseUrl}$relativePath';
  }
}
