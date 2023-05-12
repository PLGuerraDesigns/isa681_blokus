import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
<<<<<<< HEAD
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/board_view.dart';
=======
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/game_over_dialog.dart';
>>>>>>> dev-cst
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/piece_collection_view.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameBoardPage extends StatefulWidget {
  const GameBoardPage({super.key, required this.supabase, required this.debug});

  final SupabaseClient supabase;
  final bool debug;

  @override
  State<GameBoardPage> createState() => GameBoardPageState();
}

class GameBoardPageState extends State<GameBoardPage> {
  late final BlokusGame _game;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _game = BlokusGame(
      supabase: widget.supabase,
<<<<<<< HEAD
      onGameOverCallback: (playerWon) async {
=======
      onGameOverCallback: () async {
>>>>>>> dev-cst
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
<<<<<<< HEAD
            return AlertDialog(
              title: Text(playerWon ? 'You Won!' : 'You lost...'),
              actions: [
                TextButton(
                  onPressed: () {
                    _game.returnToLobbyCallback(context);
                    _openLobbyDialog();
                  },
                  child: const Text('Back to Lobby'),
                ),
              ],
=======
            return GameOverDialog(
              returnToLobbyCallback: _game.returnToLobbyCallback,
              participants: _game.participants,
>>>>>>> dev-cst
            );
          }),
        );
      },
    );

    // await for a frame so that the widget mounts
    await Future.delayed(Duration.zero);

    if (!widget.debug) {
      if (mounted) {
        _openLobbyDialog();
      }
    } else {
      _game.debug = true;
<<<<<<< HEAD
      _game.startNewGame(_game.opponents);
=======
      _game.startNewGame(_game.participants);
>>>>>>> dev-cst
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
            onGameStarted: _game.onGameStarted,
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
                padding: const EdgeInsets.all(
                  10,
                ),
                child: Row(
<<<<<<< HEAD
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
=======
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
>>>>>>> dev-cst
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            PieceCollectionView(
                              player: _game.player,
                              debug: widget.debug,
<<<<<<< HEAD
=======
                              colorTurnValue: _game.colorTurnValue,
>>>>>>> dev-cst
                            ),
                            _game.opponents.length < 3
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[2],
                                    topSpacing: true,
                                    debug: widget.debug,
<<<<<<< HEAD
=======
                                    colorTurnValue: _game.colorTurnValue,
>>>>>>> dev-cst
                                  ),
                          ]),
                    ),
                    const SizedBox(width: 8),
                    AspectRatio(
                      aspectRatio: 1,
                      child: BoardView(
                        board: value.board,
                        addPieceToBoardCallback: (int id, Piece piece) =>
<<<<<<< HEAD
                            _game.addPieceToBoard(id, piece),
=======
                            _game.addPieceToBoard(
                          context,
                          id,
                          piece,
                        ),
>>>>>>> dev-cst
                        debug: widget.debug,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: [
<<<<<<< HEAD
                            PieceCollectionView(
                              player: _game.opponents[0],
                              debug: widget.debug,
                            ),
=======
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
>>>>>>> dev-cst
                            _game.opponents.length < 2
                                ? Container()
                                : PieceCollectionView(
                                    player: _game.opponents[1],
                                    topSpacing: true,
                                    debug: widget.debug,
<<<<<<< HEAD
=======
                                    colorTurnValue: _game.colorTurnValue,
>>>>>>> dev-cst
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
