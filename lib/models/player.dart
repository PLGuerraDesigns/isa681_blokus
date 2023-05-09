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

  Color _primaryColor = Colors.grey;

  Color _secondaryColor = Colors.grey;

  List<Piece> _pieces = [];

  List<Piece> get pieces => _pieces;

  Color get primaryColor => _primaryColor;

  Color get secondaryColor => _secondaryColor;

  bool get hasSecondaryCollection => _secondaryColor.value != Colors.grey.value;

  Player(
      {required this.isOpponent,
      String? uid,
      String? username,
      String? roomID}) {
    this.roomID = roomID ?? '';
    this.uid = uid ?? const Uuid().v4();
    this.username = username ?? UsernameGen().generate().toUpperCase();
  }

  void setData(Map<dynamic, dynamic> playerData) {
    updatePrimaryColor(int.parse(playerData['primaryColorValue']));
    updateSecondaryColor(int.parse(playerData['secondaryColorValue']));

    _pieces = [];
    for (dynamic pieceData in playerData['remainingPieces']) {
      Piece piece = Piece(
        playerUID: pieceData['playerUID'],
        color: Color(int.parse(pieceData['color'])),
        shape: PieceShape.values
            .where((piece) => piece.name == pieceData['shape'])
            .first,
        isSecondarySet: pieceData['isSecondarySet'],
      );
      _pieces.add(piece);
    }
  }

  void updatePrimaryColor(int colorValue) {
    try {
      _primaryColor = Color(colorValue);
    } catch (_) {
      _primaryColor = Colors.grey;
      throw ("Failed to update players ($username) primary color.");
    }
  }

  void updateSecondaryColor(int colorValue) {
    try {
      _secondaryColor = Color(colorValue);
    } catch (_) {
      _secondaryColor = Colors.grey;
      throw ("Failed to update players ($username) secondary color.");
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

  void removePlayerPiece(Piece piece) {
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
      'remainingPieces': pieces.map((Piece piece) => piece.data()).toList(),
    };
  }

  @override
  String toString() {
    return json.encode(data());
  }
}
