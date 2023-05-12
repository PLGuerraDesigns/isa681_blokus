import 'dart:async';
import 'dart:convert';
import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/custom_snackbar.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlokusGame extends FlameGame with ChangeNotifier {
  final String playerUID;

  final String playerEmail;

  final SupabaseClient supabase;

  /// Callback to notify the parent when the game ends.
  final void Function() onGameOverCallback;

  final Board _board = Board(numberOfColumns: 20);

  /// Holds the RealtimeChannel to sync game states
  late RealtimeChannel realtimeChannel;

  bool isGameOver = true;

  late final Player _player;

  int _colorTurnValue = Colors.blue.value;

  Piece? _lastPiecePlayed;

  int get colorTurnValue => _colorTurnValue;

  List<Player> participants = [];

  bool debug = false;

  Player get player => _player;

  BuildContext context;

  List<Player> get opponents =>
      participants.where((participant) => participant != player).toList();

  Board get board => _board;

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

    _checkPlayerTurn();
    _checkPlayerForfeit();
    _sendPlayerMove();

    if (participants.where((player) => player.pieces.isEmpty).isNotEmpty) {
      _endGame();
    }
  }

  void onGameStarted(roomID, allParticipants) async {
    // await a frame to allow subscribing to a new channel in a realtime callback
    await Future.delayed(const Duration(milliseconds: 20));

    startNewGame(roomID, allParticipants);
  }

  void startNewGame(String roomID, List<Player> allParticipants) async {
    participants = allParticipants;

    realtimeChannel =
        supabase.channel(roomID, opts: const RealtimeChannelConfig(self: true));

    realtimeChannel
        .on(RealtimeListenTypes.broadcast, ChannelFilter(event: 'game_state'),
            (payload, [_]) {
      _board.setUpBoard(payload['boardConfiguration']);
      updateOpponent(payload['playerData']);
      updateLastPiecePlayed(payload['lastPiecePlayed']);
    }).subscribe();

    _board.resetBoard();
    _player.initializePieces();
    for (Player opponent in opponents) {
      opponent.initializePieces();
    }
    isGameOver = false;
    await Future.delayed(const Duration(milliseconds: 200));
    notifyListeners();
  }

  void _checkPlayerTurn() {
    List<Color> colorTurnOrder = [
      Colors.blue,
      Colors.amber[600]!,
      Colors.red,
      Colors.green,
    ];
    int colorTurnOrderIndex = 0;
    bool skipUser = false;

    participants.sort((a, b) => colorTurnOrder
        .indexOf(a.primaryColor)
        .compareTo(colorTurnOrder.indexOf(b.primaryColor)));

    if (_lastPiecePlayed != null) {
      colorTurnOrderIndex = colorTurnOrder.indexWhere(
        (color) => color.value == _lastPiecePlayed!.color.value,
      );

      do {
        skipUser = false;
        colorTurnOrderIndex = (colorTurnOrderIndex + 1) % 4;

        for (Player player in participants) {
          if ((player.primaryColor.value ==
                      colorTurnOrder[colorTurnOrderIndex].value ||
                  player.primaryColor.value ==
                      colorTurnOrder[colorTurnOrderIndex].value) &&
              player.leftTheGame) {
            skipUser = true;
          }
        }
      } while (skipUser);

      _colorTurnValue = colorTurnOrder[colorTurnOrderIndex].value;
    }
  }

  void _checkPlayerForfeit() {
    DateTime currentDateTime = DateTime.now();
    int minutesElapsed = 0;
    for (Player player in opponents) {
      minutesElapsed =
          currentDateTime.difference(player.lastActiveDateTime).inMinutes;
      if (minutesElapsed > 4) {
        player.leftTheGame = true;
        notifyListeners();
      }
    }
    if (participants.where((player) => !player.leftTheGame).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar()
          .floatingMessage(
              context, 'All players have left the game.', Colors.orange[700]!));
      _endGame();
    }
  }

  void _sendPlayerMove() async {
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
    notifyListeners();
  }

  void returnToLobbyCallback(BuildContext context) async {
    context.go('/');
    await supabase.removeChannel(realtimeChannel);
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
  void _endGame() {
    isGameOver = true;
    for (Player player in participants) {
      player.calculateFinalScore();
      print(player.finalScore);
    }
    onGameOverCallback();
  }
}
