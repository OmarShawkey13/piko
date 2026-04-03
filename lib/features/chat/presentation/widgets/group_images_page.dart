import 'package:flutter/material.dart';
import 'package:piko/core/models/message_model.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/primary/primary_app_bar.dart';
import 'package:piko/core/utils/constants/spacing.dart';
import 'package:piko/features/chat/presentation/widgets/media_message.dart';

class GroupImagesPage extends StatelessWidget {
  final List<MessageModel> images;

  const GroupImagesPage({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.black,
      appBar: PrimaryAppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        titleWidget: Text(
          "ألبوم الصور (${images.length})",
          style: TextStylesManager.bold18.copyWith(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 30),
        itemCount: images.length,
        separatorBuilder: (context, index) => verticalSpace16,
        itemBuilder: (context, index) {
          final msg = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: MediaMessage(
              imageUrl: msg.imageUrl,
              fileSize: msg.fileSize,
              messageId: msg.id,
              isUploading: msg.isUploading,
              localPath: msg.localPath,
              width: double.infinity,
              height: 400,
              allMessages: images,
              currentIndex: index,
            ),
          );
        },
      ),
    );
  }
}
