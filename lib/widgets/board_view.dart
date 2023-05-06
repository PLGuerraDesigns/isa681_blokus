import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/board_cell_view.dart';
import 'package:flutter/material.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.board,
    required this.addPieceToBoardCallback,
  });
  final Board board;
  final Function(int, Piece) addPieceToBoardCallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(20),
      child: Container(
        color: Colors.white,
        child: GridView.custom(
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board.numberOfColumns),
          childrenDelegate: SliverChildListDelegate(
            List.generate(
              board.numberOfColumns * board.numberOfColumns,
              (index) {
                return BoardCellView(
                  cell: board.getCell(index),
                  addPieceToBoardCallback: (piece) =>
                      addPieceToBoardCallback(index, piece),
                  // debug: true,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
