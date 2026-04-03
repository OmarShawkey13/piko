import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final double size;

  const MediaPlaceholder({
    super.key,
    this.width,
    this.height,
    this.size = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? size,
      height: height ?? size,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }
}
