import 'dart:async';
<<<<<<< HEAD

=======
import 'dart:convert';
>>>>>>> dev-plg
import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:blokus/widgets/custom_snackbar.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD

class BlokusGame extends FlameGame with ChangeNotifier {
  BlokusGame({
    required this.onGameOver,
    required this.onGameStateUpdate,
  });

  /// Callback to notify the parent when the game ends.
  final void Function(bool didWin) onGameOver;

  /// Callback for when the game state updates.
  final void Function(
    List<dynamic> remainingPieces,
    String boardConfiguration,
  ) onGameStateUpdate;

  final Board _board = Board(numberOfColumns: 20);

  bool isGameOver = true;

  final Player _player = Player(isOpponent: false);

  Player _opponent = Player(isOpponent: true);

  get player => _player;

  get opponent => _opponent;

  get board => _board;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void>? onLoad() async {
    // _player.setPieces(PieceShape.values.map((e) {
    //   return Piece(color: Colors.green, shape: e);
    // }).toList());
    // _opponent.setPieces(PieceShape.values.map((e) {
    //   return Piece(color: Colors.amber, shape: e);
    // }).toList());

    await super.onLoad();
  }
=======
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
>>>>>>> dev-plg

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
<<<<<<< HEAD
=======
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
  }

  @override
>>>>>>> dev-plg
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

<<<<<<< HEAD
    onGameStateUpdate(
        _player.pieces.map((Piece piece) => piece.shape.name).toList(),
        _board.configuration);

    if (_player.pieces.isEmpty || _opponent.pieces.isEmpty) {
      endGame(false);
    }
  }

  void startNewGame(List<Player> opponents) {
    isGameOver = false;
    _opponent = opponents.first;

    _board.resetBoard();

    _player.setPieces(PieceShape.values.map((e) {
      return Piece(
          color: _player.colors.first, shape: e, playerUID: _player.uid);
    }).toList());
    _opponent.setPieces(PieceShape.values.map((e) {
      return Piece(
          color: _opponent.colors.first, shape: e, playerUID: _opponent.uid);
    }).toList());
  }

  void updateOpponentPieceList({required List<dynamic> opponentPieces}) {
    _opponent.setPieces(opponentPieces
        .map((piecesAsString) => Piece(
            playerUID: _opponent.uid,
            color: _opponent.colors.first,
            shape: PieceShape.values
                .where((piece) => piece.name == piecesAsString)
                .first))
        .toList());
  }

  void updateBoard(String boardConfiguration) {
    _board.setUpBoard(boardConfiguration);
  }

  void addPieceToBoard(int id, Piece piece) {
    if (_board.validPiecePlacement(targetCellID: id, piece: piece)) {
      _board.addPiece(targetCellID: id, piece: piece);
      _player.removePlayerPiece(piece);
      // onGameStateUpdate(_player.pieces.map((e) => e.shape.name).toList());
      notifyListeners();
    }
  }

  /// Called when either the player or the opponent has run out of health points
  void endGame(bool playerWon) {
    isGameOver = true;
    onGameOver(playerWon);
=======
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
>>>>>>> dev-plg
  }
}
