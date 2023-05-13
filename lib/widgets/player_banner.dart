import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/message_banner.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.player,
    required this.playersTurn,
    required this.messageBannerColor,
  });
  final bool playersTurn;
  final Color messageBannerColor;
  final Player player;

  @override
  Widget build(BuildContext context) {
    return MessageBanner(
      message: player.isOpponent ? "PLAYER'S TURN" : "YOUR TURN",
      enabled: playersTurn,
      color: messageBannerColor,
      child: _playerListTile(),
    );
  }

  Widget _playerListTile() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: player.primaryColor,
          width: 2,
        ),
        gradient: LinearGradient(colors: [
          player.primaryColor.withOpacity(playersTurn ? 0.4 : 0.2),
          player.hasSecondaryCollection
              ? player.secondaryColor.withOpacity(playersTurn ? 0.4 : 0.2)
              : player.primaryColor.withOpacity(playersTurn ? 0.4 : 0.2)
        ]),
      ),
      child: ListTile(
        enabled: false,
        leading: CircleAvatar(
            backgroundColor: player.primaryColor,
            child: RandomAvatar(player.username,
                trBackground: true, height: 50, width: 50)),
        title: Text(
          player.username,
          style: TextStyle(
            fontSize: 16,
            color: player.primaryColor.darken(0.6),
            fontFamily: 'LemonMilk',
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          'Pieces Remaining: ${player.pieces.length}',
          style: TextStyle(
              fontSize: 14,
              color: player.primaryColor.darken(0.6),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
