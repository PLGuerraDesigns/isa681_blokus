import 'dart:async';
import 'dart:convert';
import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlokusGame extends FlameGame with ChangeNotifier {
  BlokusGame({
    required this.onGameOverCallback,
    required this.supabase,
  });

  final SupabaseClient supabase;

  /// Callback to notify the parent when the game ends.
  final void Function(bool didWin) onGameOverCallback;

  final Board _board = Board(numberOfColumns: 20);

  /// Holds the RealtimeChannel to sync game states
  RealtimeChannel? realtimeChannel;

  bool isGameOver = true;

  final Player _player = Player(
      isOpponent: false, primaryColor: Colors.blue, secondaryColor: Colors.red);

  List<Player> _opponents = [
    Player(
        isOpponent: true,
        primaryColor: Colors.green,
        secondaryColor: Colors.amber[700])
  ];

  bool debug = false;

  Player get player => _player;

  List<Player> get opponents => _opponents;

  Board get board => _board;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) async {
    super.update(dt);
    if (isGameOver) {
      return;
    }
    if (!debug) {
      ChannelResponse response;

      do {
        response = await realtimeChannel!.send(
          type: RealtimeListenTypes.broadcast,
          event: 'game_state',
          payload: {
            'boardConfiguration': _board.configuration,
            'playerData': json.encode(_player.data()),
          },
        );
        await Future.delayed(Duration.zero);
        notifyListeners();
      } while (response == ChannelResponse.rateLimited);
    }

    if (_player.pieces.isEmpty ||
        _opponents.where((opponent) => opponent.pieces.isEmpty).isNotEmpty) {
      endGame(false);
    }
    if (debug) {
      notifyListeners();
    }
  }

  void onGameStarted(roomID, opponents) async {
    // await a frame to allow subscribing to a new channel in a realtime callback
    await Future.delayed(Duration.zero);

    startNewGame(opponents);

    notifyListeners();

    realtimeChannel =
        supabase.channel(roomID, opts: const RealtimeChannelConfig(ack: true));

    realtimeChannel!
        .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_state'),
            (payload, [_]) {
      _board.setUpBoard(payload['boardConfiguration']);
      updateOpponent(payload['playerData']);

      // if (player.pieces.isEmpty ||
      //     opponents.where((opponent) => opponent.pieces.isEmpty).isNotEmpty) {
      //   if (!isGameOver) {
      //     isGameOver = true;
      //     onGameOver(true);
      //   }
      // }
    }).subscribe();
  }

  void returnToLobbyCallback(BuildContext context) async {
    Navigator.of(context).pop();
    await supabase.removeChannel(realtimeChannel!);
  }

  void startNewGame(List<Player> newOpponents) {
    isGameOver = false;
    _opponents = newOpponents;

    _board.resetBoard();
    _player.initializePieces();
    for (Player opponent in _opponents) {
      opponent.initializePieces();
    }
    notifyListeners();
  }

  void updateOpponent(String opponentPayload) {
    Map<dynamic, dynamic> playerData = jsonDecode(opponentPayload);
    if (opponents.map((opponent) => opponent.uid).contains(playerData['uid'])) {
      Player opponent = opponents
          .where((opponent) => opponent.uid == playerData['uid'])
          .first;
      opponent.setData(playerData);
    }
  }

  void addPieceToBoard(int id, Piece piece) {
    if (_board.validPiecePlacement(targetCellID: id, piece: piece)) {
      _board.addPiece(targetCellID: id, piece: piece);
      _player.removePlayerPiece(piece);
    }
  }

  /// Called when either the player or the opponent has run out of health points
  void endGame(bool playerWon) {
    isGameOver = true;
    onGameOverCallback(playerWon);
  }
}
