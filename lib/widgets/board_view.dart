import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/board_cell_view.dart';
import 'package:flutter/material.dart';

class BoardView extends StatelessWidget {
  const BoardView(
      {super.key,
      required this.board,
      required this.addPieceToBoardCallback,
      this.debug});
  final Board board;
  final bool? debug;
  final Function(int, Piece) addPieceToBoardCallback;
  static final List<Color> cornerColors = [
    Colors.blue,
<<<<<<< HEAD
    Colors.amber[700]!,
    Colors.green,
    Colors.red
=======
    Colors.amber[600]!,
    Colors.red,
    Colors.green,
>>>>>>> dev-cst
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          GridView.custom(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            childrenDelegate: SliverChildListDelegate(
              List.generate(
                cornerColors.length,
                (index) {
                  return Container(
                    color: cornerColors[index],
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            margin: const EdgeInsets.all(10),
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
                      debug: debug,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
