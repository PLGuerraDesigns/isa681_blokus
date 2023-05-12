import 'dart:convert';

import 'package:blokus/models/player.dart';
import 'package:uuid/uuid.dart';

class Room {
  late final String id;
  final String name;
  final List<Player> _players = [];

  List<Player> get players => _players;

  Room({
    required this.name,
    String? id,
    List<Player>? players,
  }) {
    this.id = id ?? const Uuid().v4();
    if (players != null) {
      loadPlayers(players);
    }
  }

  void loadPlayers(List<Player> players) {
    for (Player newPlayer in players) {
      if (!_players
          .map((currentPlayers) => currentPlayers.uid)
          .contains(newPlayer.uid)) {
        if (players.length < 4) {
          _players.add(newPlayer);
        }
      }
    }
  }

  void addPlayer(Player player) {
    if (_players.length < 4) {
      if (!_players.contains(player)) {
        _players.add(player);
      }
    } else {
      throw '$name already contains the maximum number of players.';
    }
  }

  void removePlayerWithUID(String playerUID) {
    _players.removeWhere((player) => player.uid == playerUID);
  }

  Map<String, dynamic> data() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return json.encode(data());
  }
}
