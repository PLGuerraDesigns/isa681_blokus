import 'package:blokus/models/game.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/services/authentication.dart';
import 'package:blokus/services/auto_logout.dart';
import 'package:blokus/widgets/board_view.dart';
import 'package:blokus/widgets/game_over_dialog.dart';
import 'package:blokus/widgets/lobby_dialog.dart';
import 'package:blokus/widgets/piece_collection_view.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class GameBoardPage extends StatefulWidget {
  const GameBoardPage({
    super.key,
    required this.playerAuthentication,
    this.debug,
  });

  final bool? debug;
  final PlayerAuthentication playerAuthentication;

  @override
  State<GameBoardPage> createState() => GameBoardPageState();
}

class GameBoardPageState extends State<GameBoardPage> {
  late AutoLogout autoLogout;
  late final BlokusGame _game;
  bool debug = false;

  @override
  void initState() {
    super.initState();
    debug = widget.debug ?? false;
    _initialize();
  }

  Future<void> _initialize() async {
    _game = BlokusGame(
      context: context,
      supabase: widget.playerAuthentication.supabase,
      onGameOverCallback: () async {
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: ((context) {
            return GameOverDialog(
              returnToLobbyCallback: widget.playerAuthentication.signOut,
              participants: _game.participants,
              pieceHistory: _game.gamePieceHistory,
              allOpponentsLeft: _game.opponents
                  .where((opponent) => !opponent.leftTheGame)
                  .isEmpty,
            );
          }),
        );
      },
      playerEmail: widget.playerAuthentication.playerEmail,
      playerUID: widget.playerAuthentication.playerUID,
    );

    autoLogout = AutoLogout(
        context: context,
        signOutCallback: () {
          _game.forfeitPlayer();
          widget.playerAuthentication.signOut();
        },
        timeout: Duration(minutes: _game.timeOutInMinutes));
    autoLogout.resetTimer();
    // await for a frame so that the widget mounts
    await Future.delayed(Duration.zero);

    if (!debug) {
      if (mounted) {
        _openLobbyDialog();
      }
    } else {
      _game.startNewGame('Room 1', _game.opponents);
    }
  }

  void _openLobbyDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return LobbyDialog(
              player: _game.player,
              supabase: widget.playerAuthentication.supabase,
              onGameStarted: _game.onGameStarted,
              signOutCallback: widget.playerAuthentication.signOut,
              timerResetCallback: () => autoLogout.resetTimer());
        });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        autoLogout.resetTimer();
      },
      child: Scaffold(
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
                      AspectRatio(
                        aspectRatio: 1,
                        child: BoardView(
                          board: value.board,
                          addPieceToBoardCallback: (int id, Piece piece) =>
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
        ),
      ),
    );
  }
}
