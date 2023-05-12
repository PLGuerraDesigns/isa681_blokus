import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressedCallback,
    required this.title,
    this.iconData,
    this.backgroundColor,
    this.margin,
    this.padding,
    this.circular,
  });
  final Function()? onPressedCallback;
  final String title;
  final IconData? iconData;
  final Color? backgroundColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool? circular;

  @override
  Widget build(BuildContext context) {
    Color color = backgroundColor ?? Colors.blue;
    return Padding(
      padding: margin ?? const EdgeInsets.all(4.0),
      child: MaterialButton(
        color: color,
        shape: circular == true
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        disabledColor: color.withOpacity(0.25),
        onPressed: onPressedCallback,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(0),
          child: Row(
            children: [
              iconData == null
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
