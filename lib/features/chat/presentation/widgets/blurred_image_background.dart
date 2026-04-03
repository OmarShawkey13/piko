import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:piko/features/chat/presentation/widgets/media_placeholder.dart';
import 'package:piko/core/theme/colors.dart';

class BlurredImageBackground extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const BlurredImageBackground({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          color: ColorsManager.black.withValues(alpha: 0.1),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: ColorsManager.black.withValues(alpha: 0.2)),
          ),
        ),
      ),
      placeholder: (context, url) => MediaPlaceholder(
        width: width,
        height: height,
      ),
      errorWidget: (context, url, error) => MediaPlaceholder(
        width: width,
        height: height,
      ),
    );
  }
}
