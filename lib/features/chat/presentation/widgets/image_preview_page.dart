import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const PrimaryAppBar(
        backgroundColor: Colors.transparent,
        leading: CloseButton(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            maxScale: 4,
            minScale: 1,
            child: Image.file(
              File(imagePath),
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 50),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
