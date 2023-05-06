import "package:blokus/models/piece.dart";
import "package:blokus/models/player.dart";
import "package:blokus/widgets/player_avatar.dart";
import "package:blokus/widgets/player_banner.dart";
import "package:flutter/material.dart";

import 'piece_view.dart';

class PlayerPieceBank extends StatelessWidget {
  const PlayerPieceBank({
    super.key,
    required this.player,
  });
  final Player player;

  List<Widget> gamePieces() {
    final List<Widget> gamePieces = [];
    PieceView gamePiece;

    for (Piece piece in player.pieces) {
      gamePiece = PieceView(
        piece: piece,
      );
      gamePieces.add(
        player.isOpponent
            ? Opacity(opacity: 0.4, child: gamePiece)
            : Draggable(
                data: gamePiece,
                feedback: PieceView(
                  piece: piece,
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
    Color color =
        player.pieces.isEmpty ? Colors.grey[400] : player.pieces.first.color;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayerBanner(
            player: player,
            color: color,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: color)),
              child: GridView.custom(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  crossAxisCount: 3,
                ),
                childrenDelegate: SliverChildListDelegate(gamePieces()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
