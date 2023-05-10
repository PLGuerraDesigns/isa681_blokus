import "package:blokus/models/piece.dart";
import "package:blokus/models/player.dart";
import "package:blokus/widgets/player_banner.dart";
import "package:flutter/material.dart";

import 'piece_view.dart';

class PieceCollectionView extends StatelessWidget {
  const PieceCollectionView({
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
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlayerBanner(
            player: player,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color: player.primaryColor,
                ),
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      player.primaryColor.withOpacity(0.1),
                      player.hasSecondaryCollection
                          ? player.secondaryColor.withOpacity(0.1)
                          : player.primaryColor.withOpacity(0.1)
                    ]),
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  GridView.custom(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      crossAxisCount: 3,
                    ),
                    childrenDelegate: SliverChildListDelegate(gamePieces()),
                  ),
                  player.isOpponent || player.pieces.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: FloatingActionButton(
                            tooltip: 'Rotate Pieces',
                            elevation: 0,
                            backgroundColor:
                                player.primaryColor.withOpacity(0.6),
                            hoverColor: player.primaryColor.withOpacity(1),
                            hoverElevation: 8,
                            mini: true,
                            child: const RotatedBox(
                                quarterTurns: 1,
                                child:
                                    Icon(Icons.rotate_90_degrees_cw_outlined)),
                            onPressed: () => player.rotatePieces(),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
