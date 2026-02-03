import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

enum AppAvatarSize { small, medium, large, xlarge }

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double? customSize;
  final AppAvatarSize size;
  final String? initials;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final List<Color>? gradientColors;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.customSize,
    this.size = AppAvatarSize.medium,
    this.initials,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.gradientColors,
  });

  double _getRawSize() {
    if (customSize != null) return customSize!;
    switch (size) {
      case AppAvatarSize.small: return 32;
      case AppAvatarSize.medium: return 48;
      case AppAvatarSize.large: return 80;
      case AppAvatarSize.xlarge: return 110;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawSize = _getRawSize();
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final defaultGradients = [const Color(0xFF2563EB), const Color(0xFF22D3EE)];

    return Container(
      width: rawSize,
      height: rawSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: hasImage ? null : [
          BoxShadow(
            color: (gradientColors?.first ?? defaultGradients.first).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: showBorder
            ? Border.all(
                color: borderColor ?? Colors.white24,
                width: borderWidth,
              )
            : null,
        gradient: hasImage ? null : LinearGradient(
          colors: gradientColors ?? defaultGradients,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: _buildAvatarContent(context, rawSize),
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context, double rawSize) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      String url = imageUrl!;
      
      // Auto-fix DiceBear PNG to SVG (more reliable, higher quality, fixes EncodingError)
      if (url.contains('dicebear.com') && url.contains('/png')) {
        url = url.replaceAll('/png', '/svg');
      }

      final isSvg = url.toLowerCase().contains('.svg') || url.toLowerCase().contains('/svg');

      if (isSvg) {
        return _buildSvgImage(context, url, rawSize);
      }

      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmer(context, rawSize),
        errorWidget: (context, url, error) {
          debugPrint("AppAvatar: Failed to load image from $url. Error: $error");
          return _buildFallback(context, rawSize, isError: true);
        },
      );
    }
    return _buildFallback(context, rawSize);
  }

  Widget _buildSvgImage(BuildContext context, String url, double rawSize) {
    return SvgPicture.network(
      url,
      fit: BoxFit.cover,
      width: rawSize,
      height: rawSize,
      placeholderBuilder: (context) => _buildShimmer(context, rawSize),
    );
  }

  Widget _buildShimmer(BuildContext context, double rawSize) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      highlightColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      child: Container(
        width: rawSize,
        height: rawSize,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFallback(BuildContext context, double rawSize, {bool isError = false}) {
    if (initials != null && initials!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D), // Premium dark background inside the ring
          gradient: RadialGradient(
            colors: [
              const Color(0xFF2563EB).withValues(alpha: 0.15),
              Colors.transparent,
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Text(
              initials!.toUpperCase(),
              style: TextStyle(
                color: const Color(0xFF22D3EE),
                fontWeight: FontWeight.w900,
                fontSize: rawSize * 0.45,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: isError 
        ? Colors.redAccent.withValues(alpha: 0.05) 
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      child: Center(
        child: Icon(
          isError ? Icons.cloud_off_rounded : Icons.person_rounded,
          color: isError ? Colors.redAccent : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          size: rawSize * 0.5,
        ),
      ),
    );
  }
}
