import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.player,
  });
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: player.primaryColor,
          width: 2,
        ),
        gradient: LinearGradient(colors: [
          player.primaryColor.withOpacity(0.2),
          player.hasSecondaryCollection
              ? player.secondaryColor.withOpacity(0.2)
              : player.primaryColor.withOpacity(0.2)
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
              fontSize: 14,
              color: player.primaryColor,
              fontFamily: 'LemonMilk',
              fontWeight: FontWeight.w300),
        ),
        subtitle: Text(
          'Pieces Remaining: ${player.pieces.length}',
          style: TextStyle(fontSize: 14, color: player.primaryColor),
        ),
      ),
    );
  }
}
