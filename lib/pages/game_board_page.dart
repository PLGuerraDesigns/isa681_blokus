<<<<<<< HEAD
import 'dart:convert';
import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/player_piece_bank.dart';
=======
import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/services/authentication.dart';
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/game_over_dialog.dart';
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/piece_collection_view.dart';
>>>>>>> dev-plg
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

class GameBoardPage extends StatefulWidget {
<<<<<<< HEAD
  const GameBoardPage({super.key, required this.supabase});

  final SupabaseClient supabase;
=======
  const GameBoardPage({
    super.key,
    required this.playerAuthentication,
    this.debug,
  });

  final bool? debug;
  final PlayerAuthentication playerAuthentication;
>>>>>>> dev-plg

  @override
  State<GameBoardPage> createState() => GameBoardPageState();
}

class GameBoardPageState extends State<GameBoardPage> {
  late final BlokusGame _game;
  bool debug = false;

<<<<<<< HEAD
  /// Holds the RealtimeChannel to sync game states
  RealtimeChannel? _gameChannel;

=======
>>>>>>> dev-plg
  @override
  void initState() {
    super.initState();
    debug = widget.debug ?? false;
    _initialize();
  }

  Future<void> _initialize() async {
    _game = BlokusGame(
<<<<<<< HEAD
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
=======
      context: context,
      supabase: widget.playerAuthentication.supabase,
      onGameOverCallback: () async {
>>>>>>> dev-plg
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
<<<<<<< HEAD
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
=======
            return GameOverDialog(
              returnToLobbyCallback: _game.returnToLobbyCallback,
              participants: _game.participants,
>>>>>>> dev-plg
            );
          }),
        );
      },
      playerEmail: widget.playerAuthentication.playerEmail,
      playerUID: widget.playerAuthentication.playerUID,
    );

    // await for a frame so that the widget mounts
    await Future.delayed(Duration.zero);

<<<<<<< HEAD
    if (mounted) {
      _openLobbyDialog();
=======
    if (!debug) {
      if (mounted) {
        _openLobbyDialog();
      }
    } else {
      _game.debug = true;
      _game.startNewGame('Room 1', _game.participants);
>>>>>>> dev-plg
    }
  }

  void _openLobbyDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LobbyDialog(
            player: _game.player,
<<<<<<< HEAD
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
=======
            supabase: widget.playerAuthentication.supabase,
            onGameStarted: _game.onGameStarted,
            signOutCallback: widget.playerAuthentication.signOut,
>>>>>>> dev-plg
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blokus'),
        actions: [
          IconButton(
              tooltip: 'SIGN OUT',
              onPressed: widget.playerAuthentication.signOut,
              icon: const Icon(
                Icons.logout_outlined,
              ))
        ],
      ),
<<<<<<< HEAD
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
=======
      body: ChangeNotifierProvider<BlokusGame>.value(
        value: _game,
        child: Consumer<BlokusGame>(builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              GameWidget(game: _game),
              Padding(
                padding: const EdgeInsets.all(
                  10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            PieceCollectionView(
                              player: _game.player,
                              debug: widget.debug,
                              colorTurnValue: _game.colorTurnValue,
                            ),
                            _game.opponents.length < 3
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[2],
                                    topSpacing: true,
                                    debug: widget.debug,
                                    colorTurnValue: _game.colorTurnValue,
                                  ),
                          ]),
                    ),
                    const SizedBox(width: 8),
>>>>>>> dev-plg
                    AspectRatio(
                      aspectRatio: 1,
                      child: BoardView(
                        board: value.board,
                        addPieceToBoardCallback: (int id, Piece piece) =>
<<<<<<< HEAD
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
=======
                            _game.addPieceToBoard(
                          context,
                          id,
                          piece,
                        ),
                        debug: widget.debug,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _game.opponents.isEmpty
                                ? const Expanded(
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  )
                                : PieceCollectionView(
                                    player: _game.opponents[0],
                                    debug: widget.debug,
                                    colorTurnValue: _game.colorTurnValue,
                                  ),
                            _game.opponents.length < 2
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[1],
                                    topSpacing: true,
                                    debug: widget.debug,
                                    colorTurnValue: _game.colorTurnValue,
                                  ),
                          ]),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
>>>>>>> dev-plg
      ),
    );
  }
}
