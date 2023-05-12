import 'package:blokus/models/player.dart';
<<<<<<< HEAD
=======
import 'package:flame/extensions.dart';
>>>>>>> dev-cst
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.player,
<<<<<<< HEAD
  });
=======
    required this.playersTurn,
    required this.messageBannerColor,
  });
  final bool playersTurn;
  final Color messageBannerColor;
>>>>>>> dev-cst
  final Player player;

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
=======
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: !playersTurn
          ? _playerListTile()
          : Banner(
              message: player.isOpponent ? "PLAYER'S TURN" : "YOUR TURN",
              location: BannerLocation.topStart,
              color: messageBannerColor,
              child: _playerListTile(),
            ),
    );
  }

  Widget _playerListTile() {
>>>>>>> dev-cst
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
<<<<<<< HEAD
          player.primaryColor.withOpacity(0.2),
          player.hasSecondaryCollection
              ? player.secondaryColor.withOpacity(0.2)
              : player.primaryColor.withOpacity(0.2)
=======
          player.primaryColor.withOpacity(playersTurn ? 0.4 : 0.2),
          player.hasSecondaryCollection
              ? player.secondaryColor.withOpacity(playersTurn ? 0.4 : 0.2)
              : player.primaryColor.withOpacity(playersTurn ? 0.4 : 0.2)
>>>>>>> dev-cst
        ]),
      ),
      child: ListTile(
        enabled: false,
        leading: CircleAvatar(
            backgroundColor: player.primaryColor,
            child: RandomAvatar(player.uid,
                trBackground: true, height: 50, width: 50)),
        title: Text(
          player.username,
          style: TextStyle(
<<<<<<< HEAD
              fontSize: 14,
              color: player.primaryColor,
              fontFamily: 'LemonMilk',
              fontWeight: FontWeight.w300),
        ),
        subtitle: Text(
          'Pieces Remaining: ${player.pieces.length}',
          style: TextStyle(fontSize: 14, color: player.primaryColor),
=======
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
>>>>>>> dev-cst
        ),
      ),
    );
  }
}
