import 'package:flutter/material.dart';

class MessageBanner extends StatelessWidget {
  const MessageBanner({
    super.key,
    required this.message,
    required this.enabled,
    required this.color,
    required this.child,
  });
  final bool enabled;
  final Color color;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return !enabled
        ? child
        : ClipRRect(
            child: Banner(
              message: message,
              location: BannerLocation.topStart,
              color: color,
              child: child,
            ),
          );
  }
}
