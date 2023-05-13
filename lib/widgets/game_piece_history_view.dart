import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/piece_view.dart';
import 'package:flutter/material.dart';

class GamePieceHistoryView extends StatelessWidget {
  const GamePieceHistoryView({
    super.key,
    required this.players,
    required this.pieceHistory,
  });
  final List<Piece> pieceHistory;
  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return pieceHistory.isEmpty
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[400]!),
                color: Colors.grey[200]),
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              crossAxisCount: 5,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
              children: gamePieces(),
            ),
          );
  }

  List<Widget> gamePieces() {
    final List<Widget> gamePieces = [];
    String username = '';
    gamePieces.addAll(pieceHistory.map((piece) {
      username = '';
      for (Player player in players) {
        if (player.uid == piece.playerUID) {
          username = player.username;
        }
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.grey[400]!,
            ),
            color: Colors.grey[200],
          ),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.loose,
            children: [
              PieceView(
                piece: Piece(
                  color: piece.color,
                  shape: piece.shape,
                  playerUID: piece.playerUID,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  color: Colors.white60,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      username,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList());
    return gamePieces;
  }
}
