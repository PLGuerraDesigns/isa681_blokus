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
    int playerIndex = 0;
    bool allPrimariesAssigned = true;
    for (Color color in [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.amber[600]!
    ]) {
      playerIndex = Random().nextInt(roomToLaunch.players.length);

      // Assign single color to random user if grey
      if (roomToLaunch.players[playerIndex].primaryColor == Colors.grey) {
        roomToLaunch.players[playerIndex]
            .updatePrimaryColor(color.value.toString());
        continue;
      }

      // If user already has a non-grey primary color assigned,
      // check if all users have a primary color
      for (Player player in roomToLaunch.players) {
        if (player.primaryColor == Colors.grey) {
          allPrimariesAssigned = false;
        }
      }

      // All users have primary colors, so assign as secondary if none assigned
      if (allPrimariesAssigned) {
        while (
            roomToLaunch.players[playerIndex].secondaryColor != Colors.grey) {
          playerIndex = Random().nextInt(roomToLaunch.players.length);
        }
        roomToLaunch.players[playerIndex]
            .updateSecondaryColor(color.value.toString());
        roomToLaunch.players[playerIndex].hasSecondaryCollection = true;
      }
    }
  }

  // Start the game if someone has started a game with you
  bool gameStartedCallback(
      dynamic payload, dynamic ref, Function onGameStarted) {
    final participants = List<dynamic>.from(payload['participants']);

    if (participants
        .map((participant) => participant['uid'])
        .contains(player.uid)) {
      // Update player colors
      player.updatePrimaryColor(participants
          .where((participant) => participant['uid'] == player.uid)
          .first['primaryColorValue']
          .toString());

      player.hasSecondaryCollection = participants
          .where((participant) => participant['uid'] == player.uid)
          .first['hasSecondaryCollection'];
      if (player.hasSecondaryCollection) {
        player.updateSecondaryColor(participants
            .where((participant) => participant['uid'] == player.uid)
            .first['secondaryColorValue']
            .toString());
      }

      final opponents = rooms
          .where((room) => room.id == selectedRoomID)
          .first
          .players
          .where((element) => element.uid != player.uid)
          .toList();

      final roomID = payload['room_id'] as String;
      onGameStarted(roomID, opponents);
      return true;
    }
    return false;
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
