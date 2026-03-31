import 'package:flutter/material.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/constants/constants.dart';
import 'package:piko/core/utils/constants/spacing.dart';

class AttachmentMenu extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCameraTap;
  final VoidCallback onVideoTap;
  final VoidCallback onGalleryTap;

  const AttachmentMenu({
    super.key,
    required this.isDark,
    required this.onCameraTap,
    required this.onVideoTap,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F2F) : ColorsManager.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsetsDirectional.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AttachmentItem(
                icon: Icons.camera_alt_rounded,
                label: appTranslation().get("camera"),
                color: Colors.orange,
                isDark: isDark,
                onTap: onCameraTap,
              ),
              _AttachmentItem(
                icon: Icons.videocam_rounded,
                label: appTranslation().get("video"),
                color: Colors.pink,
                isDark: isDark,
                onTap: onVideoTap,
              ),
              _AttachmentItem(
                icon: Icons.image_rounded,
                label: appTranslation().get("gallery"),
                color: Colors.purple,
                isDark: isDark,
                onTap: onGalleryTap,
              ),
            ],
          ),
          verticalSpace20,
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _AttachmentItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          verticalSpace8,
          Text(
            label,
            style: TextStylesManager.medium12.copyWith(
              color: isDark
                  ? ColorsManager.darkTextPrimary
                  : ColorsManager.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
