import 'package:blokus/models/piece.dart';
import 'package:flutter/material.dart';

class Cell extends StatefulWidget {
  const Cell({super.key, this.color, this.boardCell});
  final Color? color;
  final bool? boardCell;

  @override
  CellState createState() => CellState();
}

class CellState extends State<Cell> {
  late Color cellColor;
  bool occupied = false;

  @override
  void initState() {
    super.initState();
    cellColor = widget.color ?? Colors.grey[300]!;
    occupied = widget.color != null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.boardCell == true) {
      return DragTarget<Piece>(
        builder: (BuildContext context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(1),
            color: cellColor,
          );
        },
        onWillAccept: (data) {
          if (!occupied) {
            setState(() {
              if (data.runtimeType == Piece) {
                cellColor = (data as Piece).color.withOpacity(0.25);
              }
            });
          }
          return data.runtimeType == Piece;
        },
        onLeave: (data) {
          if (!occupied) {
            cellColor = Colors.grey[300]!;
          }
        },
        onAccept: (Piece data) {
          if (!occupied) {
            setState(() {
              cellColor = data.color;
              occupied = true;
            });
          }
        },
      );
    }
    return Container(
      margin: const EdgeInsets.all(0.5),
      color: cellColor,
    );
  }
}
