import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/primary/loading_indicator.dart';
import 'package:piko/features/chat/presentation/widgets/blurred_image_background.dart';
import 'package:piko/features/chat/presentation/widgets/media_download_controls.dart';
import 'package:piko/features/chat/presentation/widgets/media_placeholder.dart';
import 'package:piko/features/chat/presentation/widgets/image_preview_page.dart';

class MediaMessage extends StatefulWidget {
  final String? imageUrl;
  final String? fileSize;
  final String messageId;
  final bool isUploading;
  final String? localPath;

  const MediaMessage({
    super.key,
    this.imageUrl,
    this.fileSize,
    required this.messageId,
    this.isUploading = false,
    this.localPath,
  });

  @override
  State<MediaMessage> createState() => _MediaMessageState();
}

class _MediaMessageState extends State<MediaMessage> {
  static const double _kImageSize = 250.0;

  bool _isDownloading = false;
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  File? _localFile;

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void didUpdateWidget(MediaMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.localPath != oldWidget.localPath ||
        widget.imageUrl != oldWidget.imageUrl) {
      _initializeImage();
    }
  }

  @override
  void dispose() {
    _progressNotifier.dispose();
    super.dispose();
  }

  void _initializeImage() {
    if (widget.localPath != null) {
      final file = File(widget.localPath!);
      if (file.existsSync()) {
        setState(() => _localFile = file);
        return;
      }
    }

    if (widget.imageUrl != null) {
      _checkLocalFile();
    }
  }

  Future<void> _checkLocalFile() async {
    final path = await _getLocalPath();
    final file = File(path);

    if (await file.exists() && mounted) {
      setState(() => _localFile = file);
    }
  }

  Future<String> _getLocalPath() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) return "";

    final base = directory.path.split('Android').first;
    final dir = Directory(
      "${base}Android/media/com.example.piko/Piko/Media/Piko Images",
    );

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final extension =
        widget.imageUrl?.split('.').last.split('?').first ?? "jpg";

    return "${dir.path}/${widget.messageId}.$extension";
  }

  Future<void> _downloadFile() async {
    if (_isDownloading || widget.imageUrl == null) return;

    setState(() {
      _isDownloading = true;
      _progressNotifier.value = 0;
    });

    try {
      final path = await _getLocalPath();
      final file = File(path);

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.imageUrl!));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final sink = file.openWrite();
      final total = response.contentLength ?? 0;
      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (total != 0) {
          final newProgress = received / total;
          if ((newProgress - _progressNotifier.value).abs() > 0.01) {
            _progressNotifier.value = newProgress;
          }
        }
      }

      await sink.close();
      client.close();

      if (mounted) {
        setState(() {
          _localFile = file;
          _isDownloading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
      debugPrint("Download error: $e");
    }
  }

  void _navigateToPreview() {
    if (_localFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute<Object>(
          builder: (_) => ImagePreviewPage(
            imagePath: _localFile!.path,
            heroTag: widget.imageUrl ?? widget.messageId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_localFile != null) {
      return _buildLocalImage();
    }

    if (widget.imageUrl == null) {
      return const MediaPlaceholder(size: _kImageSize);
    }

    return _buildNetworkImage();
  }

  Widget _buildLocalImage() {
    return GestureDetector(
      onTap: _navigateToPreview,
      child: Hero(
        tag: widget.imageUrl ?? widget.messageId,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.file(
              _localFile!,
              fit: BoxFit.cover,
              width: _kImageSize,
              height: _kImageSize,
              cacheWidth: 500,
              cacheHeight: 500,
              errorBuilder: (_, _, _) =>
                  const MediaPlaceholder(size: _kImageSize),
            ),
            if (widget.isUploading)
              _buildOverlay(
                const LoadingIndicator(color: ColorsManager.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return GestureDetector(
      onTap: _isDownloading ? null : _downloadFile,
      child: Stack(
        alignment: Alignment.center,
        children: [
          BlurredImageBackground(imageUrl: widget.imageUrl!, size: _kImageSize),
          if (!_isDownloading) MediaDownloadButton(fileSize: widget.fileSize),
          if (_isDownloading)
            MediaDownloadProgress(progressNotifier: _progressNotifier),
        ],
      ),
    );
  }

  Widget _buildOverlay(Widget child) {
    return Container(
      width: _kImageSize,
      height: _kImageSize,
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(child: child),
    );
  }
}
