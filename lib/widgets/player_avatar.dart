import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    required this.transparentBackground,
    this.allowEdit,
    this.score,
  });
  final Player player;
  final bool? allowEdit;
  final bool transparentBackground;
  final String? score;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Tooltip(
        message: allowEdit != true ? '' : 'EDIT PROFILE',
        waitDuration: const Duration(milliseconds: 500),
        child: GestureDetector(
          onTap: allowEdit != true
              ? null
              : () {
                  // TODO: IMPLEMENT EDIT PLAYER PROFILE
                  throw ('MISSING EDIT PLAYER PROFILE IMPLEMENTATION.');
                },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                width: 100,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: player.primaryColor,
                      child: RandomAvatar(
                        player.uid,
                        trBackground: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${player.username}\n',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              allowEdit != true
                  ? Container()
                  : const Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
