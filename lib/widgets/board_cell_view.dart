import 'package:blokus/models/cell.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/cell_view.dart';
import 'package:blokus/widgets/piece_view.dart';
import 'package:flutter/material.dart';

class BoardCellView extends StatefulWidget {
  const BoardCellView({
    super.key,
    required this.cell,
    required this.addPieceToBoardCallback,
    this.debug,
  });
  final Cell cell;
  final Function(Piece) addPieceToBoardCallback;
  final bool? debug;

  @override
  State<BoardCellView> createState() => _BoardCellViewState();
}

class _BoardCellViewState extends State<BoardCellView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PieceView>(
      builder: (BuildContext context, candidateData, rejectedData) {
        return Stack(
          children: [
            CellView(
              color: widget.cell.color,
            ),
            widget.debug == true
                ? Text(
                    widget.cell.id.toString(),
                    style: const TextStyle(color: Colors.black),
                  )
                : Container(),
          ],
        );
      },
      onWillAccept: (data) {
        if (!widget.cell.isOccupied()) {
          setState(() {
            if (data.runtimeType == PieceView) {
              widget.cell.color =
                  (data as PieceView).piece.color.withOpacity(0.3);
            }
          });
        }
        return data.runtimeType == PieceView;
      },
      onLeave: (data) {
        setState(() {
          if (!widget.cell.isOccupied()) {
            widget.cell.color = Colors.grey[300]!;
          }
        });
      },
      onAccept: (PieceView data) {
        setState(() {
          widget.cell.color = Colors.grey[300]!;
        });
        widget.addPieceToBoardCallback(data.piece);
      },
    );
  }
}
