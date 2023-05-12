import 'package:blokus/models/lobby.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/custom_button.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:blokus/widgets/room_list_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LobbyDialog extends StatefulWidget {
  const LobbyDialog({
    super.key,
    required this.onGameStarted,
    required this.supabase,
    required this.player,
  });

  final SupabaseClient supabase;
  final void Function(String gameId, List<Player> allParticipants)
      onGameStarted;
  final Player player;

  @override
  State<LobbyDialog> createState() => LobbyDialogState();
}

class LobbyDialogState extends State<LobbyDialog> {
  late Lobby _lobby;

  @override
  void initState() {
    super.initState();
    _lobby = Lobby(
      player: widget.player,
      realtimeChannel: widget.supabase.channel(
        'lobby',
        opts: const RealtimeChannelConfig(self: true),
      ),
    );

    _lobby.realtimeChannel
        .on(
          RealtimeListenTypes.presence,
          ChannelFilter(event: 'sync'),
          (payload, [ref]) => setState(() {
            _lobby.roomSyncCallback(payload, ref);
          }),
        )
        .on(
          RealtimeListenTypes.broadcast,
          ChannelFilter(event: 'game_start'),
          (payload, [ref]) => _lobby.gameStartedCallback(
              context, payload, ref, widget.onGameStarted),
        )
        .subscribe(
          (status, [ref]) => _lobby.subscribeCallback(status, ref),
        );
  }

  @override
  void dispose() {
    widget.supabase.removeChannel(_lobby.realtimeChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'LOBBY',
            style: TextStyle(
                fontFamily: 'LemonMilk', fontSize: 60, color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: PlayerAvatar(
              transparentBackground: false,
              player: widget.player,
              allowEdit: true,
            ),
          ),
        ],
      ),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'ROOMS',
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontWeight: FontWeight.w300,
                    fontSize: 32,
                    color: Colors.blue[600],
                  ),
                ),
                const Spacer(),
                CustomButton(
                  title: 'NEW ROOM',
                  iconData: Icons.add,
                  backgroundColor: Colors.green,
                  onPressedCallback: _lobby.rooms
                              .map((room) => room.id)
                              .contains(_lobby.createdRoomID) ||
                          _lobby.selectedRoomID.isNotEmpty
                      ? null
                      : _lobby.createRoomCallback,
                ),
              ],
            ),
            const Divider(
              height: 20,
              color: Colors.blue,
            ),
            RoomListView(
              rooms: _lobby.rooms,
              selectedRoomID: _lobby.selectedRoomID,
              loading: _lobby.loading,
              leaveRoomCallback: _lobby.leaveRoomCallback,
              joinRoomCallback: (roomID) => _lobby.joinRoomCallback(roomID),
            ),
          ]),
      actionsPadding: const EdgeInsets.all(15),
      actions: [
        MaterialButton(
          color: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          disabledColor: Colors.blue.withOpacity(0.25),
          onPressed: _lobby.selectedRoomID.isEmpty ||
                  _lobby.rooms
                          .where((room) => room.id == _lobby.selectedRoomID)
                          .first
                          .players
                          .length <
                      2
              ? null
              : () {
                  setState(() {
                    _lobby.loading = true;
                  });
                  _lobby.startGameCallback();
                },
          child: const Text(
            'START',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
