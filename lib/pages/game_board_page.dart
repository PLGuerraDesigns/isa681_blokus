import 'dart:convert';
import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/player_piece_bank.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameBoardPage extends StatefulWidget {
  const GameBoardPage({super.key, required this.supabase});

  final SupabaseClient supabase;

  @override
  State<GameBoardPage> createState() => GameBoardPageState();
}

class GameBoardPageState extends State<GameBoardPage> {
  late final BlokusGame _game;

  /// Holds the RealtimeChannel to sync game states
  RealtimeChannel? _gameChannel;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _game = BlokusGame(
      onGameStateUpdate: (remainingPieces, boardConfiguration) async {
        ChannelResponse response;
        do {
          response = await _gameChannel!.send(
            type: RealtimeListenTypes.broadcast,
            event: 'game_state',
            payload: {
              'boardConfiguration': boardConfiguration,
              'remainingPieces': remainingPieces,
            },
          );

          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {});
        } while (response == ChannelResponse.rateLimited);
      },
      onGameOver: (playerWon) async {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
            return AlertDialog(
              title: Text(playerWon ? 'You Won!' : 'You lost...'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await widget.supabase.removeChannel(_gameChannel!);
                    _openLobbyDialog();
                  },
                  child: const Text('Back to Lobby'),
                ),
              ],
            );
          }),
        );
      },
    );

    // await for a frame so that the widget mounts
    await Future.delayed(Duration.zero);

    if (mounted) {
      _openLobbyDialog();
    }
  }

  void _openLobbyDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LobbyDialog(
            player: _game.player,
            supabase: widget.supabase,
            onGameStarted: (gameId, opponents) async {
              // await a frame to allow subscribing to a new channel in a realtime callback
              await Future.delayed(Duration.zero);

              _game.startNewGame(opponents);

              setState(() {});

              _gameChannel = widget.supabase.channel(gameId,
                  opts: const RealtimeChannelConfig(ack: true));

              _gameChannel!.on(RealtimeListenTypes.broadcast,
                  ChannelFilter(event: 'game_state'), (payload, [_]) {
                final opponentPieces = payload['remainingPieces'];
                _game.updateOpponentPieceList(
                  opponentPieces: opponentPieces,
                );
                _game.updateBoard(payload['boardConfiguration']);

                if (_game.opponent.pieces.isEmpty) {
                  if (!_game.isGameOver) {
                    _game.isGameOver = true;
                    _game.onGameOver(true);
                  }
                }
              }).subscribe();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blokus'),
      ),
      body: Stack(
        children: [
          GameWidget(game: _game),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ChangeNotifierProvider<BlokusGame>.value(
              value: _game,
              child: Consumer<BlokusGame>(builder: (context, value, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    PlayerPieceBank(
                      player: _game.player,
                    ),
                    const SizedBox(width: 10),
                    AspectRatio(
                      aspectRatio: 1,
                      child: BoardView(
                        board: value.board,
                        addPieceToBoardCallback: (int id, Piece piece) =>
                            _game.addPieceToBoard(id, piece),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PlayerPieceBank(
                      player: _game.opponent,
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
