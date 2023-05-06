import 'package:blokus/constants/custom_enums.dart';
import 'package:flutter/material.dart';

class Piece {
  final Color color;
  final PieceShape shape;
  final String playerUID;

  Piece({required this.color, required this.shape, required this.playerUID});

  @override
  String toString() {
    return "($shape, ${color.value}, $playerUID)";
  }
}
