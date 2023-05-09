import 'dart:convert';
import 'dart:math';

import 'package:blokus/models/player.dart';
import 'package:blokus/models/room.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Lobby {
  List<Room> rooms = [];
  bool loading = false;
  List<Player> _activePlayers = [];
  String createdRoomID = '';
  String selectedRoomID = '';

  final Player player;
  final RealtimeChannel realtimeChannel;

  Lobby({required this.player, required this.realtimeChannel});

  /// Unpack the incoming data.
  void roomSyncCallback(dynamic payload, dynamic ref) {
    final presenceState = realtimeChannel.presenceState();

    // Unpack all active players
    _activePlayers = presenceState.values
        .map((presences) => Player(
            isOpponent: true,
            uid: ((presences.first as Presence).payload['uid']),
            username: ((presences.first as Presence).payload['username']),
            roomID:
                ((presences.first as Presence).payload['room_id']).toString()))
        .toList();

    rooms = [];
    // Unpack rooms
    for (var presences in presenceState.values) {
      List roomsListPayload =
          jsonDecode((presences.first as Presence).payload['rooms'].toString());
      for (var roomPayload in roomsListPayload) {
        var room = Room(
            id: roomPayload['id'],
            name: roomPayload['name'],
            players: _activePlayers
                .where((player) => player.roomID == roomPayload['id'])
                .toList());

        if (!rooms.map((room) => room.id).contains(room.id) &&
            room.players.isNotEmpty) {
          rooms.add(room);
        }
      }
    }
  }

  /// The data to subscribe to.
  void subscribeCallback(dynamic status, dynamic ref) async {
    if (status == 'SUBSCRIBED') {
      await realtimeChannel.track({
        'uid': player.uid,
        'rooms': rooms.map((room) => room.data()).toList(),
      });
    }
  }

  void createRoomCallback() async {
    var newRoom = Room(
      name: 'Room ${rooms.length + 1}',
    );
    rooms.add(newRoom);
    createdRoomID = newRoom.id;
    joinRoomCallback(createdRoomID);
  }

  void joinRoomCallback(String roomID) async {
    Room roomToJoin = rooms.where((room) => room.id == roomID).first;
    roomToJoin.addPlayer(player);
    selectedRoomID = roomID;
    sendSyncData();
  }

  void leaveRoomCallback() async {
    for (Room room in rooms) {
      if (room.players.map((e) => e.uid).contains(player.uid)) {
        room.removePlayerWithUID(player.uid);
        if (room.players.isEmpty) {
          rooms.remove(room);
        }
      }
    }
    selectedRoomID = '';
    sendSyncData();
  }

  void startGameCallback() async {
    Room roomToLaunch = rooms.where((room) => room.id == selectedRoomID).first;

    _assignPlayerColors(roomToLaunch);

    // print(roomToLaunch.players.map((player) =>
    // '${player.username}: (${player.primaryColor.value}, ${player.secondaryColor.value}) (hasSecondaryCollection: ${player.hasSecondaryCollection})'));

    await realtimeChannel.send(
      type: RealtimeListenTypes.broadcast,
      event: 'game_start',
      payload: {
        'room_id': selectedRoomID,
        'participants':
            roomToLaunch.players.map((player) => player.data()).toList(),
      },
    );
  }

  void _assignPlayerColors(Room roomToLaunch) {
    int colorIndex = 0;
    int playerIndex = Random().nextInt(roomToLaunch.players.length);
    List<Color> colors = [
      Colors.blue, // 4280391411
      Colors.red, // 4294198070
      Colors.green, // 4283215696
      Colors.amber[600]! // 4294947584
    ];

    for (Player player in roomToLaunch.players) {
      colorIndex = Random().nextInt(colors.length);
      player.updatePrimaryColor(colors[colorIndex].value);
      colors.remove(colors[colorIndex]);
    }

    while (colors.isNotEmpty) {
      while (roomToLaunch.players[playerIndex].hasSecondaryCollection) {
        playerIndex = Random().nextInt(roomToLaunch.players.length);
      }
      colorIndex = Random().nextInt(colors.length);
      roomToLaunch.players[playerIndex]
          .updateSecondaryColor(colors[colorIndex].value);
      colors.remove(colors[colorIndex]);
    }
  }

  // Start the game if someone has started a game with you
  void gameStartedCallback(BuildContext context, dynamic payload, dynamic ref,
      Function onGameStarted) {
    final participants = List<dynamic>.from(payload['participants']);

    // Ensure we belong to the started room
    if (participants
        .map((participant) => participant['uid'])
        .contains(player.uid)) {
      var playerData = participants
          .where((participant) => participant['uid'] == player.uid)
          .first;

      // Update player colors
      player.updatePrimaryColor(int.parse(playerData['primaryColorValue']));
      player.updateSecondaryColor(int.parse(playerData['secondaryColorValue']));

      List<Player> opponents = rooms
          .where((room) => room.id == selectedRoomID)
          .first
          .players
          .where((element) => element.uid != player.uid)
          .toList();

      for (Player opponent in opponents) {
        var opponentData = participants
            .where((participant) => participant['uid'] == opponent.uid)
            .first;

        opponent.setData(opponentData);
      }

      final roomID = payload['room_id'] as String;
      onGameStarted(roomID, opponents);
      Navigator.of(context).pop();
    }
  }

  void sendSyncData() async {
    await realtimeChannel.track({
      'uid': player.uid,
      'username': player.username,
      'room_id': selectedRoomID,
      'rooms': json.encode(rooms.map((room) => room.data()).toList()),
    });
  }
}
