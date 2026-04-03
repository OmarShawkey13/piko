import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/features/chat/presentation/widgets/media_placeholder.dart';

class ImagePreviewPage extends StatefulWidget {
  final List<MessageModel> messages;
  final int initialIndex;

  const ImagePreviewPage({
    super.key,
    required this.messages,
    required this.initialIndex,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PrimaryAppBar(
        backgroundColor: Colors.transparent,
        leading: const CloseButton(color: Colors.white),
        titleWidget: Text(
          "${_currentIndex + 1} / ${widget.messages.length}",
          style: TextStylesManager.medium16.copyWith(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.messages.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final msg = widget.messages[index];
          return Center(
            child: InteractiveViewer(
              maxScale: 4,
              minScale: 1,
              child: Hero(
                tag: msg.id,
                child: _buildImage(msg),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(MessageModel msg) {
    // 1. Check local file first
    if (msg.localPath != null && File(msg.localPath!).existsSync()) {
      return Image.file(
        File(msg.localPath!),
        errorBuilder: (_, _, _) => _buildError(),
      );
    }

    // 2. Check network image with cache
    if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: msg.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) => _buildError(),
      );
    }

    return _buildError();
  }

  Widget _buildError() {
    return const MediaPlaceholder(size: 200);
  }
}
