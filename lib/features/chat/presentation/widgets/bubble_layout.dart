import 'package:flutter/material.dart';

class BubbleLayout extends StatelessWidget {
  final bool isMe;
  final Widget child;

  const BubbleLayout({super.key, required this.isMe, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: child,
      ),
    );
  }
}
