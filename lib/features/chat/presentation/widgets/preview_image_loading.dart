import 'package:flutter/material.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';

class PreviewImageLoading extends StatelessWidget {
  final ImageChunkEvent? loadingProgress;

  const PreviewImageLoading({super.key, this.loadingProgress});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoadingIndicator(
        size: 50,
        color: Colors.white,
      ),
    );
  }
}
