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

  bool hasSecondaryCollection = false;

  Color _primaryColor = Colors.grey;

  Color _secondaryColor = Colors.grey;

  List<Piece> _pieces = [];

  get pieces => _pieces;

  get primaryColor => _primaryColor;

  get secondaryColor => _secondaryColor;

  Player(
      {required this.isOpponent,
      String? uid,
      String? username,
      String? roomID}) {
    this.roomID = roomID ?? '';
    this.uid = uid ?? const Uuid().v4();
    this.username = username ?? UsernameGen().generate();
  }

  void updatePrimaryColor(String colorString) {
    try {
      _primaryColor = Color(int.parse(colorString));
    } catch (_) {
      throw ("Failed to update players ($username) primary color.");
    }
  }

  void updateSecondaryColor(String colorString) {
    try {
      _secondaryColor = Color(int.parse(colorString));
    } catch (_) {
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

  void setPieces(List<Piece> pieces) {
    _pieces = pieces;
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
      'hasSecondaryCollection': hasSecondaryCollection,
    };
  }

  @override
  String toString() {
    return json.encode(data());
  }
}
