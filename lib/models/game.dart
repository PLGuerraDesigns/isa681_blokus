import 'dart:async';

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

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) {
      return;
    }

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
  }
}
