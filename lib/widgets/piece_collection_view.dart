import "package:blokus/models/piece.dart";
import "package:blokus/models/player.dart";
import "package:blokus/widgets/player_banner.dart";
import "package:flutter/material.dart";

import 'piece_view.dart';

class PieceCollectionView extends StatelessWidget {
  const PieceCollectionView({
    super.key,
    required this.player,
    required this.colorTurnValue,
    this.topSpacing,
    this.debug,
  });
  final Player player;
  final bool? topSpacing;
  final bool? debug;
  static late bool playersTurn;
  final int colorTurnValue;

  List<Widget> gamePieces() {
    final List<Widget> gamePieces = [];
    PieceView gamePiece;

    for (Piece piece in player.pieces) {
      gamePiece = PieceView(
        piece: piece,
        debug: debug,
      );
      gamePieces.add(
        (debug != true && player.isOpponent) ||
                colorTurnValue != piece.color.value
            ? Opacity(opacity: 0.4, child: gamePiece)
            : Draggable(
                data: gamePiece,
                dragAnchorStrategy: (draggable, context, position) =>
                    pointerDragAnchorStrategy(draggable, context, position),
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
    playersTurn = colorTurnValue == player.primaryColor.value ||
        colorTurnValue == player.secondaryColor.value;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topSpacing == true ? const SizedBox(height: 8) : Container(),
          PlayerBanner(
            player: player,
            playersTurn: playersTurn,
            messageBannerColor: Color(colorTurnValue),
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
                  (player.isOpponent && debug != true) || player.pieces.isEmpty
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
                            child: RotatedBox(
                                quarterTurns: debug == true ? -0 : 1,
                                child: debug == true
                                    ? Text(player.pieces.first.quarterTurns
                                        .toString())
                                    : const Icon(
                                        Icons.rotate_90_degrees_cw_outlined)),
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
