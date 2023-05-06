import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/color_picker.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class LobbyDialog extends StatefulWidget {
  const LobbyDialog({
    super.key,
    required this.onGameStarted,
    required this.supabase,
    required this.player,
  });

  final SupabaseClient supabase;
  final void Function(String gameId, List<Player> opponents) onGameStarted;
  final Player player;

  @override
  State<LobbyDialog> createState() => LobbyDialogState();
}

class LobbyDialogState extends State<LobbyDialog> {
  List<Color> _opponentColorSelection = [];
  List<Player> _players = [];
  bool _loading = false;

  late final RealtimeChannel _lobbyChannel;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  void dispose() {
    widget.supabase.removeChannel(_lobbyChannel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        ),
      ],
    );
  }
}
