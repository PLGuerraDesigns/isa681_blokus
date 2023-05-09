import 'dart:async';
import 'dart:convert';

import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/models/player.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

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
    String playerData,
  ) onGameStateUpdate;

  final Board _board = Board(numberOfColumns: 20);

  bool isGameOver = true;

  final Player _player = Player(isOpponent: false);

  List<Player> _opponents = [Player(isOpponent: true)];

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
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

    onGameStateUpdate(
        _player.pieces.map((Piece piece) => piece.data()).toList(),
        _board.configuration,
        json.encode(_player.data()));

    if (_player.pieces.isEmpty ||
        _opponents.where((opponent) => opponent.pieces.isEmpty).isNotEmpty) {
      endGame(false);
    }
  }

  void startNewGame(List<Player> opponents) {
    isGameOver = false;
    _opponents = opponents;

    _board.resetBoard();
    _player.initializePieces();
    for (Player opponent in opponents) {
      opponent.initializePieces();
    }
  }

  void updateOpponentPieceList(
      {required String opponentID, required List<dynamic> opponentPieces}) {
    Player opponent =
        opponents.where((opponent) => opponent.uid == opponentID).first;
    opponent.setPieces(opponentPieces
        .map((piecesAsJson) => Piece(
              playerUID: piecesAsJson['playerUID'],
              color: Color(int.parse(piecesAsJson['color'])),
              shape: PieceShape.values
                  .where((piece) => piece.name == piecesAsJson['shape'])
                  .first,
              isSecondarySet: piecesAsJson['isSecondarySet'],
            ))
        .toList());
  }

  void updateBoard(String boardConfiguration) {
    _board.setUpBoard(boardConfiguration);
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
    onGameOver(playerWon);
  }
}
