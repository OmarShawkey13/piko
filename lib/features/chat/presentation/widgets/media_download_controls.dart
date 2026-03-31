import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class MediaDownloadButton extends StatelessWidget {
  final String? fileSize;

  const MediaDownloadButton({super.key, this.fileSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.download, color: Colors.white, size: 30),
        verticalSpace4,
        Text(
          fileSize ?? "—",
          style: TextStylesManager.bold12.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class MediaDownloadProgress extends StatelessWidget {
  final ValueNotifier<double> progressNotifier;

  const MediaDownloadProgress({super.key, required this.progressNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: progressNotifier,
      builder: (context, progress, _) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              color: ColorsManager.primary,
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        );
      },
    );
  }
}
