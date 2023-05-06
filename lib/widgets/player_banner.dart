import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerBanner extends StatelessWidget {
  const PlayerBanner({
    super.key,
    required this.player,
    required this.color,
  });
  final Player player;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color,
          width: 2,
        ),
        color: Colors.white,
      ),
      child: ListTile(
        enabled: false,
        leading: CircleAvatar(
            backgroundColor: color,
            child: RandomAvatar(player.uid,
                trBackground: true, height: 50, width: 50)),
        title: Text(
          player.username,
          style: TextStyle(fontSize: 16, color: color),
        ),
        subtitle: Text(
          'Pieces Remaining: ${player.pieces.length}',
          style: TextStyle(fontSize: 14, color: color),
        ),
      ),
    );
  }
}
