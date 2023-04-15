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

    for (var gamePiece in PieceShape.values) {
      gamePieces.add(
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Pieces(
              pieceColor: pieceColor,
              pieceShape: gamePiece,
            )),
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
