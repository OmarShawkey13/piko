import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreviewWidget extends StatelessWidget {
  final String url;
  final bool isMe;
  final bool compact;

  const LinkPreviewWidget({
    super.key,
    required this.url,
    required this.isMe,
    this.compact = false,
  });

  String _formatUrl(String u) {
    if (u.startsWith('http')) return u;
    return 'https://$u';
  }

  Future<void> _launchURL() async {
    final formattedUrl = _formatUrl(url);
    final uri = Uri.parse(formattedUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // محاولة الفتح المباشر في حال فشل التحقق (أحياناً بسبب قيود الأندرويد 11+)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // التعامل مع الخطأ بصمت أو يمكن إضافة Toast مستقبلاً
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedUrl = _formatUrl(url);

    return GestureDetector(
      onTap: _launchURL,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 14,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isMe
              ? Colors.white.withValues(alpha: compact ? 0.05 : 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
        clipBehavior: Clip.antiAlias,
        child: IgnorePointer(
          child: AnyLinkPreview(
            key: ValueKey(formattedUrl),
            link: formattedUrl,
            displayDirection: UIDirection.uiDirectionHorizontal,
            cache: const Duration(hours: 1),
            backgroundColor: Colors.transparent,
            errorWidget: const SizedBox.shrink(),
            errorBody: '',
            errorTitle: '',
            borderRadius: 12,
            removeElevation: true,
            boxShadow: const [],
            titleStyle: TextStyle(
              color: isMe ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 13 : 14,
            ),
            bodyStyle: TextStyle(
              color: isMe ? Colors.white70 : Colors.black87,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ),
      ),
    );
  }
}
