import 'dart:convert';

import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/piece.dart';
import 'package:flutter/material.dart';
import 'package:username_gen/username_gen.dart';
import 'package:uuid/uuid.dart';

class Player {
  late final String uid;

  late final String roomID;

  late final String username;

  late final bool isOpponent;

  late Color primaryColor;

  late Color secondaryColor;

<<<<<<< HEAD
=======
  int finalScore = 0;

  Piece? _lastPiecePlayed;

>>>>>>> dev-cst
  List<Piece> _pieces = [];

  List<Piece> get pieces => _pieces;

<<<<<<< HEAD
=======
  Piece? get lastPiecePlayed => _lastPiecePlayed;

>>>>>>> dev-cst
  bool get hasSecondaryCollection => secondaryColor.value != Colors.grey.value;

  Player({
    required this.isOpponent,
    String? uid,
    String? username,
    String? roomID,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    this.roomID = roomID ?? '';
    this.uid = uid ?? const Uuid().v4();
    this.username = username ?? UsernameGen().generate().toUpperCase();
    this.primaryColor = primaryColor ?? Colors.grey;
    this.secondaryColor = secondaryColor ?? Colors.grey;
  }

<<<<<<< HEAD
  void setData(Map<dynamic, dynamic> playerData) {
=======
  void calculateFinalScore() {
    List<List<int>> indexRep = [];

    if (pieces.isEmpty) {
      finalScore = 15;
      if (_lastPiecePlayed!.shape == PieceShape.i1) {
        finalScore += 5;
      }
    }

    for (Piece piece in pieces) {
      indexRep = piece.shape.indexRepresentation;

      for (List<int> column in indexRep) {
        for (int value in column) {
          if (value == 1) {
            finalScore--;
          }
        }
      }
    }
  }

  void setData(Map<dynamic, dynamic> playerData) {
    primaryColor = Color(int.parse(playerData['primaryColorValue']));
    secondaryColor = Color(int.parse(playerData['secondaryColorValue']));

    if (playerData['lastPiecePlayed'] != null) {
      _lastPiecePlayed = Piece(
        playerUID: playerData['lastPiecePlayed']['playerUID'],
        color: Color(int.parse(playerData['lastPiecePlayed']['colorValue'])),
        shape: PieceShape.values
            .where(
                (piece) => piece.name == playerData['lastPiecePlayed']['shape'])
            .first,
        isSecondarySet: playerData['lastPiecePlayed']['isSecondarySet'],
      );
    }

>>>>>>> dev-cst
    _pieces = [];
    for (dynamic pieceData in playerData['remainingPieces']) {
      Piece piece = Piece(
        playerUID: pieceData['playerUID'],
        color: Color(int.parse(pieceData['colorValue'])),
        shape: PieceShape.values
            .where((piece) => piece.name == pieceData['shape'])
            .first,
        isSecondarySet: pieceData['isSecondarySet'],
      );
      _pieces.add(piece);
    }
  }

  void initializePieces() {
    _pieces = PieceShape.values.map((e) {
      return Piece(
        color: primaryColor,
        shape: e,
        playerUID: uid,
      );
    }).toList();
    if (hasSecondaryCollection) {
      _pieces.addAll(PieceShape.values.map((e) {
        return Piece(
          color: secondaryColor,
          shape: e,
          playerUID: uid,
          isSecondarySet: true,
        );
      }).toList());
    }
  }

  void rotatePieces() {
    for (Piece piece in pieces) {
      piece.quarterTurns += 1;
      if (piece.quarterTurns > 3) {
        piece.quarterTurns = 0;
      }
    }
  }

  void removePlayerPiece(Piece piece) {
<<<<<<< HEAD
=======
    _lastPiecePlayed = piece;
>>>>>>> dev-cst
    _pieces.remove(piece);
  }

  void reset() {
    _pieces = [];
  }

  Map<String, dynamic> data() {
    return {
      'uid': uid,
      'username': username,
      'primaryColorValue': primaryColor.value.toString(),
      'secondaryColorValue': secondaryColor.value.toString(),
<<<<<<< HEAD
=======
      'lastPiecePlayed':
          lastPiecePlayed == null ? null : lastPiecePlayed!.data(),
>>>>>>> dev-cst
      'remainingPieces': pieces.map((Piece piece) => piece.data()).toList(),
    };
  }

  @override
  String toString() {
    return json.encode(data());
  }
}
