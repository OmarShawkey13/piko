import 'package:flutter/material.dart';

class PreviewImageLoading extends StatelessWidget {
  final ImageChunkEvent? loadingProgress;

  const PreviewImageLoading({super.key, this.loadingProgress});

  @override
  Widget build(BuildContext context) {
    final progress = loadingProgress?.expectedTotalBytes != null
        ? loadingProgress!.cumulativeBytesLoaded /
              loadingProgress!.expectedTotalBytes!
        : null;

    return Center(
      child: SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          value: progress,
          color: Colors.white,
        ),
      ),
    );
  }
}
