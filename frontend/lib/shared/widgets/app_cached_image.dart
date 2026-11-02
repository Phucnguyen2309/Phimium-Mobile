import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Ảnh mạng có cache + shimmer. Nếu không có URL thì hiện nền Navy + icon nổi giống Web.
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.landscape_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(gradient: AppColors.placeholderGradient),
      alignment: Alignment.center,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          placeholderIcon,
          color: AppColors.primary,
          size: 26,
        ),
      ),
    );

    final url = imageUrl;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: (url == null || url.isEmpty)
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, _) => Shimmer.fromColors(
                baseColor: AppColors.surfaceLight,
                highlightColor: AppColors.surface,
                child: Container(
                  width: width,
                  height: height,
                  color: AppColors.surfaceLight,
                ),
              ),
              errorWidget: (context, _, __) => placeholder,
            ),
    );
  }
}
