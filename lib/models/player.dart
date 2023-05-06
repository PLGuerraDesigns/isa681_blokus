import 'package:blokus/models/piece.dart';
import 'package:flutter/material.dart';
import 'package:username_gen/username_gen.dart';
import 'package:uuid/uuid.dart';

class Player {
  late final String uid;

  late final String username;

  late final bool isOpponent;

  late List<Color> colors;

  List<Piece> _pieces = [];

  get pieces => _pieces;

  Player(
      {required this.isOpponent,
      String? uid,
      String? username,
      List<Color>? colors}) {
    this.uid = uid ?? const Uuid().v4();
    this.username = username ?? UsernameGen().generate();
    this.colors = colors ?? [Colors.grey];
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
      'colors': colors.map((color) => color.value.toString()).toList(),
    };
  }
}
