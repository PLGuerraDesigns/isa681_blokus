import 'package:flutter/material.dart';

class Cell extends StatefulWidget {
  const Cell({super.key});

  @override
  CellState createState() => CellState();
}

class CellState extends State<Cell> {
  Color cellColor = Colors.grey[300]!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (cellColor == Colors.grey[300]) {
            cellColor = Colors.grey[400]!;
          } else {
            cellColor = Colors.grey[300]!;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        color: cellColor,
      ),
    );
  }
}
