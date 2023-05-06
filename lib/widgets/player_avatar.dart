import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
  });
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RandomAvatar(player.uid, trBackground: true, height: 50, width: 50),
          const SizedBox(height: 10),
          Text(
            player.username,
            style: const TextStyle(fontSize: 14),
          )
        ],
      ),
    );
  }
}
