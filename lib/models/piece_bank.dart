import "package:blokus/constants/custom_enums.dart";
import "package:flutter/material.dart";

import "piece.dart";

class PieceBank extends StatelessWidget {
  const PieceBank({
    super.key,
    required this.pieceColor,
  });
  final Color pieceColor;

  List<Widget> gamePieces() {
    final List<Widget> gamePieces = [];
    Piece gamePiece;

    for (var pieceShape in PieceShape.values) {
      gamePiece = Piece(
        color: pieceColor,
        shape: pieceShape,
      );
      gamePieces.add(
        Draggable(
          data: gamePiece,
          feedback: Piece(
            color: pieceColor.withOpacity(0.75),
            shape: pieceShape,
            selected: true,
          ),
          childWhenDragging: Container(),
          child: gamePiece,
        ),
      );
    }
    return gamePieces;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: GridView.custom(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        childrenDelegate: SliverChildListDelegate(gamePieces()),
      ),
    );
  }
}
