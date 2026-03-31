import 'package:flutter/material.dart';

class MediaPlaceholder extends StatelessWidget {
  final double size;

  const MediaPlaceholder({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
