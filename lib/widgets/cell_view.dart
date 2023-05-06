import 'package:flutter/material.dart';

class CellView extends StatelessWidget {
  const CellView({
    super.key,
    this.color,
  });
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0.5),
      color: color ?? Colors.grey[300]!,
    );
  }
}
