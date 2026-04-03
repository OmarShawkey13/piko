import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/features/chat/presentation/widgets/image_preview_page.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';
import 'package:piko/features/chat/presentation/widgets/message_time_and_status.dart';
import 'package:piko/features/chat/presentation/widgets/group_images_page.dart';

class MessageBubbleImageGroup extends StatelessWidget {
  final List<MessageModel> images;
  final bool isMe;
  final BorderRadius radius;

  const MessageBubbleImageGroup({
    super.key,
    required this.images,
    required this.isMe,
    required this.radius,
  });

  void _openPreview(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute<Object>(
        builder: (_) => ImagePreviewPage(
          messages: images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: ColorsManager.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            _buildGrid(context),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MessageTimeAndStatus(
                  timestamp: images.isNotEmpty ? images.last.timestamp : 0,
                  isMe: isMe,
                  seen: images.isNotEmpty ? images.last.seen : false,
                  isUploading: images.any((img) => img.isUploading),
                  onImage: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final count = images.length;
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth = screenWidth * 0.75;

    if (count == 2) {
      return SizedBox(
        width: gridWidth,
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: _buildImage(images[0], height: 200, width: gridWidth / 2),
            ),
            horizontalSpace2,
            Expanded(
              child: _buildImage(images[1], height: 200, width: gridWidth / 2),
            ),
          ],
        ),
      );
    } else if (count == 3) {
      return SizedBox(
        width: gridWidth,
        child: Column(
          children: [
            _buildImage(images[0], height: 180, width: gridWidth),
            verticalSpace2,
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: _buildImage(
                      images[1],
                      height: 150,
                      width: gridWidth / 2,
                    ),
                  ),
                  horizontalSpace2,
                  Expanded(
                    child: _buildImage(
                      images[2],
                      height: 150,
                      width: gridWidth / 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (count >= 4) {
      return SizedBox(
        width: gridWidth,
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: _buildImage(
                      images[0],
                      height: 150,
                      width: gridWidth / 2,
                    ),
                  ),
                  horizontalSpace2,
                  Expanded(
                    child: _buildImage(
                      images[1],
                      height: 150,
                      width: gridWidth / 2,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpace2,
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: _buildImage(
                      images[2],
                      height: 150,
                      width: gridWidth / 2,
                    ),
                  ),
                  horizontalSpace2,
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (count > 4) {
                          // فتح صفحة ألبوم الصور (ListView) عند الضغط على الـ +
                          Navigator.push(
                            context,
                            MaterialPageRoute<Object>(
                              builder: (_) => GroupImagesPage(images: images),
                            ),
                          );
                        } else {
                          _openPreview(context, 3);
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(
                            images[3],
                            height: 150,
                            width: gridWidth / 2,
                          ),
                          if (count > 4)
                            Container(
                              color: Colors.black.withValues(alpha: 0.5),
                              child: Center(
                                child: Text(
                                  "+${count - 4}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return _buildImage(images[0], width: gridWidth);
  }

  Widget _buildImage(MessageModel msg, {double? height, double? width}) {
    final index = images.indexOf(msg);
    return MediaMessage(
      imageUrl: msg.imageUrl,
      fileSize: msg.fileSize,
      messageId: msg.id,
      isUploading: msg.isUploading,
      localPath: msg.localPath,
      height: height,
      width: width,
      allMessages: images,
      currentIndex: index,
    );
  }
}
