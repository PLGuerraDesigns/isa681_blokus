import 'dart:async';
import 'dart:convert';
import 'package:blokus/constants/custom_enums.dart';
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
  }) {
    participants = [
      player,
      Player(
          isOpponent: true,
          primaryColor: Colors.amber[600],
          secondaryColor: Colors.green),
    ];
  }

  final SupabaseClient supabase;

  /// Callback to notify the parent when the game ends.
  final void Function() onGameOverCallback;

  final Board _board = Board(numberOfColumns: 20);

  /// Holds the RealtimeChannel to sync game states
  RealtimeChannel? realtimeChannel;

  bool isGameOver = true;

  final Player _player = Player(
      isOpponent: false, primaryColor: Colors.blue, secondaryColor: Colors.red);

  final List<Color> colorTurnOrder = [
    Colors.blue,
    Colors.amber[600]!,
    Colors.red,
    Colors.green,
  ];

  int _colorTurnValue = Colors.blue.value;

  Piece? _lastPiecePlayed;

  int get colorTurnValue => _colorTurnValue;

  List<Player> participants = [];

  bool debug = false;

  Player get player => _player;

  List<Player> get opponents =>
      participants.where((participant) => participant != player).toList();

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

    _checkPlayerTurn();

    if (!debug) {
      ChannelResponse response;

      do {
        response = await realtimeChannel!.send(
          type: RealtimeListenTypes.broadcast,
          event: 'game_state',
          payload: {
            'boardConfiguration': _board.configuration,
            'playerData': json.encode(_player.data()),
            'lastPiecePlayed': _player.lastPiecePlayed == null
                ? null
                : json.encode(_player.lastPiecePlayed!.data()),
          },
        );
        await Future.delayed(Duration.zero);
        notifyListeners();
      } while (response == ChannelResponse.rateLimited);
    }

    if (participants.where((player) => player.pieces.isEmpty).isNotEmpty) {
      endGame();
    }
    if (debug) {
      notifyListeners();
    }
  }

  void onGameStarted(roomID, allParticipants) async {
    // await a frame to allow subscribing to a new channel in a realtime callback
    await Future.delayed(Duration.zero);

    startNewGame(allParticipants);

    realtimeChannel =
        supabase.channel(roomID, opts: const RealtimeChannelConfig(ack: true));

    realtimeChannel!
        .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_state'),
            (payload, [_]) {
      _board.setUpBoard(payload['boardConfiguration']);
      updateOpponent(payload['playerData']);
      updateLastPiecePlayed(payload['lastPiecePlayed']);
    }).subscribe();
  }

  void startNewGame(List<Player> allParticipants) {
    isGameOver = false;
    participants = allParticipants;

    _board.resetBoard();
    _player.initializePieces();
    for (Player opponent in opponents) {
      opponent.initializePieces();
    }
    notifyListeners();
  }

  void _checkPlayerTurn() {
    int colorTurnOrderIndex = 0;

    participants.sort((a, b) => colorTurnOrder
        .indexOf(a.primaryColor)
        .compareTo(colorTurnOrder.indexOf(b.primaryColor)));

    if (_lastPiecePlayed != null) {
      colorTurnOrderIndex = colorTurnOrder
          .indexWhere((color) => color.value == _lastPiecePlayed!.color.value);
      _colorTurnValue = colorTurnOrder[(colorTurnOrderIndex + 1) % 4].value;
    }
  }

  void returnToLobbyCallback(BuildContext context) async {
    Navigator.of(context).pop();
    await supabase.removeChannel(realtimeChannel!);
  }

  void updateLastPiecePlayed(String? lastPiecePlayedPayload) {
    if (lastPiecePlayedPayload != null) {
      dynamic pieceData = jsonDecode(lastPiecePlayedPayload);
      if (colorTurnValue == int.parse(pieceData['colorValue'])) {
        _lastPiecePlayed = Piece(
          playerUID: pieceData['playerUID'],
          color: Color(int.parse(pieceData['colorValue'])),
          shape: PieceShape.values
              .where((piece) => piece.name == pieceData['shape'])
              .first,
          isSecondarySet: pieceData['isSecondarySet'],
        );
      }
    }
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

  void addPieceToBoard(BuildContext context, int id, Piece piece) {
    if (_board.validPiecePlacement(
      targetCellID: id,
      piece: piece,
      context: context,
    )) {
      _board.addPiece(targetCellID: id, piece: piece);
      _player.removePlayerPiece(piece);
      _lastPiecePlayed = piece;
    }
  }

  /// Called when either the player or the opponent has run out of pieces.
  void endGame() {
    isGameOver = true;
    for (Player player in participants) {
      player.calculateFinalScore();
    }
    onGameOverCallback();
  }
}
