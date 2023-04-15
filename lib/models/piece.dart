import 'package:blokus/constants/custom_enums.dart';
import 'package:flutter/material.dart';

class Pieces extends StatelessWidget {
  final Color pieceColor;
  final PieceShape pieceShape;

  const Pieces({super.key, required this.pieceColor, required this.pieceShape});

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: gamePiece(pieceColor),
      childWhenDragging: gamePiece(pieceColor.withOpacity(0.25)),
      child: gamePiece(pieceColor),
    );
  }

  Widget gamePiece(Color color) {
    // TODO: GENERATE USING GRID OF CELLS
    switch (pieceShape) {
      case PieceShape.doubleSquare:
        return Container(
          width: 40,
          height: 80,
          color: color,
        );
      case PieceShape.tripleSquare:
        return Container(
          width: 40,
          height: 120,
          color: color,
        );
      case PieceShape.quadSquare:
        return Container(
          width: 80,
          height: 80,
          color: color,
        );
      case PieceShape.quintSquare:
        return Container(
          width: 40,
          height: 40,
          color: color,
        );
      default:
        return Container(
          width: 40,
          height: 40,
          color: color,
        );
    }
  }
}
