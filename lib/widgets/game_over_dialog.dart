import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.returnToLobbyCallback,
    required this.participants,
  });

  final void Function(BuildContext context) returnToLobbyCallback;
  final List<Player> participants;
  static late final Player playerWon;

  @override
  Widget build(BuildContext context) {
    participants.sort((a, b) => a.finalScore.compareTo(b.finalScore));
    participants.reverse();
    playerWon = participants.first;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Text(
            'GAME OVER',
            style: TextStyle(
                fontFamily: 'LemonMilk', fontSize: 60, color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          Text(
            playerWon.isOpponent
                ? 'Player ${playerWon.username} Won,\nBetter luck next time.'
                : 'Congratulations, You Won!',
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 20,
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'FINAL SCORES',
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontWeight: FontWeight.w300,
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const Divider(
              height: 20,
              color: Colors.blue,
            ),
            Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.4,
                  minHeight: MediaQuery.of(context).size.height * 0.25,
                ),
                child: playerScores()),
          ]),
      actionsPadding: const EdgeInsets.all(15),
      actions: [
        MaterialButton(
          color: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          disabledColor: Colors.blue.withOpacity(0.25),
          onPressed: () => returnToLobbyCallback(context),
          child: const Text(
            'RETURN TO LOBBY',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget playerScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        for (Player player in participants)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Column(
              children: [
                Text(
                  player.finalScore.toString(),
                  style: TextStyle(
                      color: player.primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                PlayerAvatar(
                  player: player,
                  score: player.uid.substring(0, 3),
                  transparentBackground: true,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
