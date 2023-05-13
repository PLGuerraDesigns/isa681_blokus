import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/cell_view.dart';
import 'package:flutter/material.dart';

class PieceView extends StatelessWidget {
  final bool? selected;
<<<<<<< HEAD
  final Piece piece;

  const PieceView({super.key, this.selected, required this.piece});
=======
  final bool? debug;
  final Piece piece;

  const PieceView({super.key, this.selected, required this.piece, this.debug});
>>>>>>> dev-plg

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: debug != true ? '' : piece.shape.name,
      waitDuration: const Duration(milliseconds: 500),
      child: FittedBox(
<<<<<<< HEAD
          fit: BoxFit.scaleDown,
          child: SizedBox(
              width: selected == true ? 125 : 100,
              height: selected == true ? 125 : 100,
              child: gamePiece())),
=======
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: selected == true
              ? piece.shape.indexRepresentation.first.length * 40
              : 100,
          height: selected == true
              ? piece.shape.indexRepresentation.first.length * 40
              : 100,
          child: gamePiece(),
        ),
      ),
>>>>>>> dev-plg
    );
  }

  Widget gamePiece() {
<<<<<<< HEAD
    List<CellView> cellViewGroup = [];
    int maxColumnLength = 3;
    for (List<int> columns in piece.shape.indexRepresentation) {
=======
    List<Widget> cellViewGroup = [];
    int maxColumnLength = 2;

    for (List<int> columns
        in piece.shape.getRotatedPieceIndexRep(piece.quarterTurns)) {
>>>>>>> dev-plg
      if (columns.length > maxColumnLength) {
        maxColumnLength = columns.length;
      }
      for (int index in columns) {
<<<<<<< HEAD
        cellViewGroup.add(
          CellView(
            color: index == 1
                ? selected == true
                    ? piece.color.withOpacity(0.75)
                    : piece.color
                : Colors.transparent,
          ),
        );
=======
        cellViewGroup.add(Stack(
          alignment: Alignment.center,
          children: [
            CellView(
              color: index == 1
                  ? selected == true
                      ? piece.color.withOpacity(0.5)
                      : piece.color
                  : Colors.transparent,
            ),
            debug == true
                ? Text(
                    index.toString(),
                    style: const TextStyle(color: Colors.black),
                  )
                : Container(),
          ],
        ));
>>>>>>> dev-plg
      }
    }

    return GridView.custom(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
<<<<<<< HEAD
          crossAxisCount: maxColumnLength),
=======
        crossAxisCount: maxColumnLength,
      ),
>>>>>>> dev-plg
      childrenDelegate: SliverChildListDelegate(cellViewGroup),
    );
  }
}
