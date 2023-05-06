import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/cell_view.dart';
import 'package:flutter/material.dart';

class PieceView extends StatelessWidget {
  final bool? selected;
  final Piece piece;

  const PieceView({super.key, this.selected, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: piece.shape.name,
      waitDuration: const Duration(milliseconds: 500),
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
              width: selected == true ? 125 : 100,
              height: selected == true ? 125 : 100,
              child: gamePiece())),
    );
  }

  Widget gamePiece() {
    List<CellView> cellViewGroup = [];
    int maxColumnLength = 3;
    for (List<int> columns in piece.shape.indexRepresentation) {
      if (columns.length > maxColumnLength) {
        maxColumnLength = columns.length;
      }
      for (int index in columns) {
        cellViewGroup.add(
          CellView(
            color: index == 1
                ? selected == true
                    ? piece.color.withOpacity(0.75)
                    : piece.color
                : Colors.transparent,
          ),
        );
      }
    }

    return GridView.custom(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: maxColumnLength),
      childrenDelegate: SliverChildListDelegate(cellViewGroup),
    );
  }
}
