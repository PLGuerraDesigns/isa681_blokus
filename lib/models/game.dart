import 'dart:async';
import 'dart:convert';
import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/services/player_turn_validation.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlokusGame extends FlameGame with ChangeNotifier {
  final String playerUID;

  final String playerEmail;

  final SupabaseClient supabase;

  final PlayerTurnValidation playerTurnValidation = PlayerTurnValidation();

  /// Callback to notify the parent when the game ends.
  final void Function() onGameOverCallback;

  final Board _board = Board(numberOfColumns: 20);

  /// Holds the RealtimeChannel to sync game states
  late RealtimeChannel realtimeChannel;

  bool isGameOver = true;

  late final Player _player;

  int _colorTurnValue = Colors.blue.value;

  List<Piece> _piecesPlayedHistory = [];

  int get colorTurnValue => _colorTurnValue;

  List<Player> participants = [];

  Player get player => _player;

  BuildContext context;

  List<Player> get opponents => participants
      .where((participant) => participant.uid != player.uid)
      .toList();

  Board get board => _board;

  List<Piece> get gamePieceHistory => _piecesPlayedHistory;

  final int timeOutInMinutes = 10;

  BlokusGame({
    required this.onGameOverCallback,
    required this.supabase,
    required this.playerEmail,
    required this.playerUID,
    required this.context,
  }) {
    _player = Player(
      isOpponent: false,
      primaryColor: Colors.blue,
      secondaryColor: Colors.red,
      emailAddress: playerEmail.split('@').first,
      uid: playerUID,
    );
    participants = [
      player,
      Player(
        isOpponent: true,
        primaryColor: Colors.amber[600],
        secondaryColor: Colors.green,
      ),
    ];
  }

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

    _colorTurnValue = playerTurnValidation.colorValueUpNext(participants,
        _piecesPlayedHistory.isEmpty ? null : _piecesPlayedHistory.last);

    participants = playerTurnValidation.checkPlayerTimeOutForfeit(
        players: participants, timeOutInMinutes: timeOutInMinutes);

    _broadcastPlayerData();
    _broadcastCheckInData();

    if (opponents.where((player) => player.leftTheGame).isNotEmpty) {
      _endGame();
    }

    if (participants.where((player) => player.pieces.isEmpty).isNotEmpty &&
        isGameOver) {
      _endGame();
    }
  }

  void onGameStarted(roomID, opponents) async {
    // await a frame to allow subscribing to a new channel in a realtime callback
    await Future.delayed(const Duration(milliseconds: 20));

    startNewGame(roomID, opponents);
  }

  void resetGameState() {
    _colorTurnValue = Colors.blue.value;
    _piecesPlayedHistory = [];
    _board.resetBoard();

    participants = [player, Player(isOpponent: true)];
    for (Player player in participants) {
      player.initializePieces();
    }
    isGameOver = false;
  }

  void startNewGame(String roomID, List<Player> opponents) async {
    participants = opponents;
    participants.add(player);
    realtimeChannel =
        supabase.channel(roomID, opts: const RealtimeChannelConfig(self: true));

    realtimeChannel
        .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_state'),
            (payload, [_]) {
      if (payload != null) {
        unpackGameData(payload);
      }
    }).on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'check_in'),
            (payload, [_]) {
      if (payload != null) {
        opponentCheckIn(payload);
      }
    }).subscribe();

    _board.resetBoard();
    for (Player player in participants) {
      player.initializePieces();
    }
    isGameOver = false;
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
  }

  void opponentCheckIn(dynamic checkInPayload) {
    if (opponents
        .map((opponent) => opponent.uid)
        .contains(checkInPayload['playerUID'])) {
      Player opponent = opponents
          .where((opponent) => opponent.uid == checkInPayload['playerUID'])
          .first;
      opponent.updateLastActivity(checkInPayload['lastActiveDateTime']);
    }
  }

  void unpackGameData(dynamic gameData) {
    if (gameData['lastPiecePlayed'] == null) {
      return;
    }
    Map<dynamic, dynamic> piecePlayedData =
        jsonDecode(gameData['lastPiecePlayed']);

    if (int.parse(piecePlayedData['colorValue']) == colorTurnValue) {
      _board.setUpBoard(gameData['boardConfiguration']);
      updateOpponent(gameData['playerData']);
      updateLastPiecePlayed(gameData['lastPiecePlayed']);
      notifyListeners();
    }
  }

  void _broadcastCheckInData() async {
    await realtimeChannel.send(
      type: RealtimeListenTypes.broadcast,
      event: 'check_in',
      payload: {
        'playerUID': player.uid,
        'lastActiveDateTime': player.lastActiveDateTime,
      },
    );
    await Future.delayed(const Duration(milliseconds: 250));
    notifyListeners();
  }

  void _broadcastPlayerData() async {
    await realtimeChannel.send(
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
  }

  void updateLastPiecePlayed(String? lastPiecePlayedPayload) {
    if (lastPiecePlayedPayload != null) {
      dynamic pieceData = jsonDecode(lastPiecePlayedPayload);
      var pieceColor = Color(int.parse(pieceData['colorValue']));
      var playerUID = pieceData['playerUID'];

      if (_piecesPlayedHistory.isEmpty ||
          (_piecesPlayedHistory.last.color != pieceColor &&
              _piecesPlayedHistory.last.playerUID != playerUID)) {
        _piecesPlayedHistory.add(
          Piece(
            playerUID: pieceData['playerUID'],
            color: pieceColor,
            shape: PieceShape.values
                .where((piece) => piece.name == pieceData['shape'])
                .first,
            isSecondarySet: pieceData['isSecondarySet'],
          ),
        );
      }
    }
  }

  void updateOpponent(dynamic opponentPayload) {
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
      _piecesPlayedHistory.add(piece);
    }

    notifyListeners();
  }

  void forfeitPlayer() async {
    player.leftTheGame = true;
    await realtimeChannel.send(
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
  }

  /// Called when either the player or the opponent has run out of pieces.
  void _endGame() {
    isGameOver = true;
    for (Player player in participants) {
      player.calculateFinalScore();
    }
    supabase.removeChannel(realtimeChannel);
    onGameOverCallback();
  }
}
