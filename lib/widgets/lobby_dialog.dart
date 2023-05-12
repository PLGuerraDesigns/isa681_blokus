<<<<<<< HEAD
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/color_picker.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
=======
import 'package:blokus/models/lobby.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/custom_button.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:blokus/widgets/room_list_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
>>>>>>> dev-plg

class LobbyDialog extends StatefulWidget {
  const LobbyDialog({
    super.key,
    required this.onGameStarted,
    required this.supabase,
    required this.player,
    required this.signOutCallback,
  });

  final SupabaseClient supabase;
<<<<<<< HEAD
  final void Function(String gameId, List<Player> opponents) onGameStarted;
=======
  final void Function(String gameId, List<Player> allParticipants)
      onGameStarted;
>>>>>>> dev-plg
  final Player player;
  final Function signOutCallback;

  @override
  State<LobbyDialog> createState() => LobbyDialogState();
}

class LobbyDialogState extends State<LobbyDialog> {
<<<<<<< HEAD
  List<Color> _opponentColorSelection = [];
  List<Player> _players = [];
  bool _loading = false;

  late final RealtimeChannel _lobbyChannel;
=======
  late Lobby _lobby;
>>>>>>> dev-plg

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD

    _lobbyChannel = widget.supabase.channel(
      'lobby',
      opts: const RealtimeChannelConfig(self: true),
    );
    _lobbyChannel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync'),
        (payload, [ref]) {
      // Update the lobby count
      final presenceState = _lobbyChannel.presenceState();

      setState(() {
        _players = presenceState.values
            .map(
              (presences) => Player(
                isOpponent: true,
                uid: (presences.first as Presence).payload['uid'],
                username: (presences.first as Presence).payload['username'],
                colors:
                    ((presences.first as Presence).payload['colors'] as List)
                        .map((colorString) => Color(int.parse(colorString)))
                        .toList(),
              ),
            )
            .toList();
      });
    }).on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_start'),
        (payload, [_]) {
      // Start the game if someone has started a game with you
      final participants = List<dynamic>.from(payload['participants']);
      if (participants
          .where((element) => element['uid'] == widget.player.uid)
          .isNotEmpty) {
        final opponents = _players
            .where((element) => element.uid != widget.player.uid)
            .toList();

        final gameId = payload['game_id'] as String;

        widget.onGameStarted(gameId, opponents);
        Navigator.of(context).pop();
      }
    }).subscribe(
      (status, [ref]) async {
        if (status == 'SUBSCRIBED') {
          await _lobbyChannel.track({
            'uid': widget.player.uid,
            'username': widget.player.username,
            'colors': widget.player.colors
                .map((color) => color.value.toString())
                .toList()
          });
        }
      },
    );
=======
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
>>>>>>> dev-plg
  }

  @override
  void dispose() {
<<<<<<< HEAD
    widget.supabase.removeChannel(_lobbyChannel);
=======
    widget.supabase.removeChannel(_lobby.realtimeChannel);
>>>>>>> dev-plg
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    _players.where(
      (player) {
        return player.uid != widget.player.uid;
      },
    ).forEach((player) {
      for (Color color in player.colors) {
        _opponentColorSelection.add(color);
      }
    });
    return AlertDialog(
      title: const Text('Lobby'),
      content: _loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${_players.length} users waiting'),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (Player player in _players) PlayerAvatar(player: player),
                ],
              ),
              const Divider(height: 20),
              ColorPicker(
                playerSelection: widget.player.colors,
                opponentSelection: _opponentColorSelection,
                colorSelectionCallback: (color) {
                  widget.player.colors = [color];
                  setState(() {});
                },
              ),
            ]),
      actions: [
        TextButton(
          onPressed: _players.length < 2
              ? null
              : () async {
                  setState(() {
                    _loading = true;
                  });
                  final gameId = const Uuid().v4();
                  await _lobbyChannel.send(
                    type: RealtimeListenTypes.broadcast,
                    event: 'game_start',
                    payload: {
                      'participants':
                          _players.map((player) => player.data()).toList(),
                      'game_id': gameId,
                    },
                  );
                },
          child: const Text('start'),
=======
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
              signOutCallback: () => widget.signOutCallback(),
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
>>>>>>> dev-plg
        ),
      ],
    );
  }
}
