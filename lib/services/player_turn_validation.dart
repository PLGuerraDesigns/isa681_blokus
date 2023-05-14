import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:flutter/material.dart';

class PlayerTurnValidation {
  final List<Color> _colorTurnOrder = [
    Colors.blue,
    Colors.amber[600]!,
    Colors.red,
    Colors.green,
  ];

  int colorValueUpNext(List<Player> participants, Piece? lastPiecePlayed) {
    int colorTurnOrderIndex = 0;
    bool skipUser = false;

    if (lastPiecePlayed == null) {
      return _colorTurnOrder.first.value;
    }

    participants.sort((a, b) => _colorTurnOrder
        .indexOf(a.primaryColor)
        .compareTo(_colorTurnOrder.indexOf(b.primaryColor)));

    colorTurnOrderIndex = _colorTurnOrder.indexWhere(
      (color) => color.value == lastPiecePlayed.color.value,
    );

    do {
      skipUser = false;
      colorTurnOrderIndex = (colorTurnOrderIndex + 1) % 4;

      for (Player player in participants) {
        if ((player.primaryColor.value ==
                    _colorTurnOrder[colorTurnOrderIndex].value ||
                player.secondaryColor.value ==
                    _colorTurnOrder[colorTurnOrderIndex].value) &&
            player.leftTheGame) {
          skipUser = true;
        }
      }
    } while (skipUser);

    return _colorTurnOrder[colorTurnOrderIndex].value;
  }

  void checkPlayerTimeOutForfeit({
    required List<Player> opponents,
    required int timeOutInMinutes,
    required Function endGameCallback,
  }) {
    DateTime currentDateTime = DateTime.now();
    int minutesElapsed = 0;
    if (opponents.isEmpty) {
      endGameCallback();
    }
    for (Player player in opponents) {
      if (player.leftTheGame) {
        endGameCallback();
      }
      minutesElapsed = currentDateTime
          .difference(DateTime.parse(player.lastActiveDateTime))
          .inMinutes;
      if (minutesElapsed > timeOutInMinutes + 1) {
        player.leftTheGame = true;
        endGameCallback();
      } else {
        player.leftTheGame = false;
      }
    }
  }
}
