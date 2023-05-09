import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';

class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({
    super.key,
    required this.player,
    this.allowEdit,
  });
  final Player player;
  final bool? allowEdit;

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
                    RandomAvatar(player.uid, height: 60),
                    const SizedBox(height: 8),
                    Text(
                      '${player.username}\n',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
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
