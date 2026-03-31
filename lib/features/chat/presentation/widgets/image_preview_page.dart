import 'dart:io';

import 'package:flutter/material.dart';
import 'package:piko/core/utils/extensions/context_extension.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => context.pop,
        ),
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
