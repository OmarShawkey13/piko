import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piko/core/theme/colors.dart';
import 'package:piko/core/theme/expandable_emoji_text.dart';
import 'package:piko/core/theme/text_styles.dart';
import 'package:piko/core/utils/cubit/chat/chat_cubit.dart';
import 'package:piko/core/utils/cubit/chat/chat_state.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubbleText extends StatelessWidget {
  final String text;
  final bool isMe;

  const MessageBubbleText({super.key, required this.text, required this.isMe});

  static final _urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatStates>(
      buildWhen: (_, state) =>
          state is ChatSearchResultsUpdatedState ||
          state is ChatSearchToggleState,
      builder: (context, state) {
        final chatCubit = ChatCubit.get(context);
        final query = chatCubit.searchQuery;

        final style = TextStylesManager.regular16.copyWith(
          color: isMe ? ColorsManager.white : ColorsManager.bubbleOtherText,
          height: 1.35,
          letterSpacing: 0.2,
        );

        if (chatCubit.isSearchActive &&
            query.isNotEmpty &&
            text.toLowerCase().contains(query.toLowerCase())) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: _buildHighlightedText(text, query, style),
          );
        }

        final matches = _urlRegex.allMatches(text);

        if (matches.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: ExpandableEmojiText(text: text, style: style),
          );
        }

        if (text.trim() == matches.first.group(0)!.trim()) {
          return const SizedBox.shrink();
        }

        final List<TextSpan> spans = [];
        int lastMatchEnd = 0;
        bool firstLinkHidden = false;

        for (final match in matches) {
          if (match.start > lastMatchEnd) {
            spans.add(
              TextSpan(
                text: text.substring(lastMatchEnd, match.start),
                style: style,
              ),
            );
          }

          if (!firstLinkHidden) {
            firstLinkHidden = true;
            lastMatchEnd = match.end;
            continue;
          }

          final url = match.group(0)!;
          spans.add(
            TextSpan(
              text: url,
              style: style.copyWith(
                color: isMe ? Colors.blue.shade200 : Colors.blue.shade600,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse(
                    url.startsWith('http') ? url : 'https://$url',
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
            ),
          );
          lastMatchEnd = match.end;
        }

        if (lastMatchEnd < text.length) {
          spans.add(
            TextSpan(text: text.substring(lastMatchEnd), style: style),
          );
        }

        if (spans.isEmpty ||
            (spans.length == 1 && spans.first.text?.trim().isEmpty == true)) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
          child: RichText(text: TextSpan(children: spans)),
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query, TextStyle style) {
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int indexOfQuery;

    while ((indexOfQuery = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfQuery > start) {
        spans.add(
          TextSpan(text: text.substring(start, indexOfQuery), style: style),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(indexOfQuery, indexOfQuery + query.length),
          style: style.copyWith(
            backgroundColor: Colors.yellow.withValues(alpha: 0.5),
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = indexOfQuery + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
