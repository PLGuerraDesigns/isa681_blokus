import 'package:flutter/material.dart';

class CustomSnackbar {
  SnackBar floatingMessage(BuildContext context, String message, Color color) {
    double minWidth = 500;
    double maxWidth = MediaQuery.of(context).size.width * 0.3;
    if (maxWidth < minWidth) {
      maxWidth = MediaQuery.of(context).size.width * 0.7;
    }

    final textWidth = message.length * 7.7;
    double width = textWidth + 40;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      width: width > maxWidth ? maxWidth : width,
      elevation: 8,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    );
  }
}
