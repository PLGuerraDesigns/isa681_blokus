import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/board_cell_view.dart';
import 'package:flutter/material.dart';

class BoardView extends StatelessWidget {
<<<<<<< HEAD
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
=======
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
    Colors.amber[600]!,
    Colors.red,
    Colors.green,
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
>>>>>>> dev-plg
      ),
    );
  }
}
