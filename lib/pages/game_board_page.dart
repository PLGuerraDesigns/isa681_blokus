import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/piece_collection_view.dart';
import 'package:blokus/widgets/player_banner.dart';
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
      onGameStateUpdate:
          (remainingPieces, boardConfiguration, playerData) async {
        ChannelResponse response;
        do {
          response = await _gameChannel!.send(
            type: RealtimeListenTypes.broadcast,
            event: 'game_state',
            payload: {
              'boardConfiguration': boardConfiguration,
              'remainingPieces': remainingPieces,
              'playerData': playerData,
            },
          );
          await Future.delayed(Duration.zero);
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
            onGameStarted: (roomID, opponents) async {
              // await a frame to allow subscribing to a new channel in a realtime callback
              await Future.delayed(Duration.zero);

              _game.startNewGame(opponents);

              setState(() {});

              _gameChannel = widget.supabase.channel(roomID,
                  opts: const RealtimeChannelConfig(ack: true));

              _gameChannel!.on(RealtimeListenTypes.broadcast,
                  ChannelFilter(event: 'game_state'), (payload, [_]) {
                for (Player opponent in opponents) {
                  _game.updateOpponentPieceList(
                      opponentID: opponent.uid,
                      opponentPieces: payload['remainingPieces']);
                }
                _game.updateBoard(payload['boardConfiguration']);

                if (_game.player.pieces.isEmpty ||
                    _game.opponents
                        .where((opponent) => opponent.pieces.isEmpty)
                        .isNotEmpty) {
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
      body: ChangeNotifierProvider<BlokusGame>.value(
        value: _game,
        child: Consumer<BlokusGame>(builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              GameWidget(game: _game),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            PieceCollectionView(
                              player: _game.player,
                            ),
                            _game.opponents.length < 3
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[2],
                                  ),
                          ]),
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
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            PieceCollectionView(
                              player: _game.opponents[0],
                            ),
                            _game.opponents.length < 2
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[1],
                                  ),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
