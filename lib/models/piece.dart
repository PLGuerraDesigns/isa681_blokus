import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/cell.dart';
import 'package:flutter/material.dart';

class Piece extends StatelessWidget {
  final Color color;
  final PieceShape shape;
  final bool? selected;

  const Piece(
      {super.key, required this.color, required this.shape, this.selected});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
            width: selected == true ? 125 : 100,
            height: selected == true ? 125 : 100,
            child: gamePiece()));
  }

  Widget gamePiece() {
    List<Cell> piece = [];
    int maxRowLength = 3;
    for (List<int> row in shape.indexRepresentation) {
      if (row.length > maxRowLength) {
        maxRowLength = row.length;
      }
      for (int index in row) {
        piece.add(Cell(color: index == 1 ? color : Colors.transparent));
      }
    }

    return GridView.custom(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxRowLength),
      childrenDelegate: SliverChildListDelegate(piece),
    );
  }
}
