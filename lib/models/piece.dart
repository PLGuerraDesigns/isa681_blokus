import 'package:blokus/constants/custom_enums.dart';
import 'package:flutter/material.dart';

class Piece {
  final Color color;
  final PieceShape shape;
  final String playerUID;
<<<<<<< HEAD

  Piece({required this.color, required this.shape, required this.playerUID});

  @override
  String toString() {
    return "($shape, ${color.value}, $playerUID)";
=======
  late final bool? isSecondarySet;
  late int quarterTurns;

  Piece({
    required this.color,
    required this.shape,
    required this.playerUID,
    bool? isSecondarySet,
    int? quarterTurns,
  }) {
    this.isSecondarySet = isSecondarySet ?? false;
    this.quarterTurns = quarterTurns ?? 0;
  }

  Map<String, dynamic> data() {
    return {
      'shape': shape.name.toString(),
      'colorValue': color.value.toString(),
      'playerUID': playerUID,
      'isSecondarySet': isSecondarySet,
      'quarterTurns': quarterTurns,
    };
  }

  @override
  String toString() {
    return json.encode(data());
>>>>>>> dev-plg
  }
}
