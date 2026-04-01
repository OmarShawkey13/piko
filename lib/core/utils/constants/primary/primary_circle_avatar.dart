import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';

class PrimaryCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final IconData? fallbackIcon;
  final double iconSize;
  final Color? backgroundColor;
  final Widget? child;
  final bool useCachedImage;

  const PrimaryCircleAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.fallbackIcon,
    this.iconSize = 24,
    this.backgroundColor,
    this.child,
    this.useCachedImage = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (useCachedImage) {
        imageProvider = CachedNetworkImageProvider(imageUrl!);
      } else {
        imageProvider = NetworkImage(imageUrl!);
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ??
          (ColorsManager.isDark ? ColorsManager.darkCard : Colors.grey[200]),
      backgroundImage: imageProvider,
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? (child ?? _buildFallback())
          : child,
    );
  }

  Widget _buildFallback() {
    if (name != null && name!.trim().isNotEmpty) {
      return Text(
        name!.trim()[0].toUpperCase(),
        style: TextStylesManager.bold16.copyWith(
          color: ColorsManager.primary,
          fontSize: radius * 0.8,
        ),
      );
    }
    return Icon(
      fallbackIcon ?? Icons.person_rounded,
      size: iconSize,
      color: ColorsManager.textSecondary.withValues(alpha: 0.4),
    );
  }
}
