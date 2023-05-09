import 'dart:convert';

import 'package:blokus/constants/custom_enums.dart';
import 'package:flutter/material.dart';

class Piece {
  final Color color;
  final PieceShape shape;
  final String playerUID;
  late final bool? isSecondarySet;

  Piece({
    required this.color,
    required this.shape,
    required this.playerUID,
    bool? isSecondarySet,
  }) {
    this.isSecondarySet = isSecondarySet ?? false;
  }

  Map<String, dynamic> data() {
    return {
      'shape': shape.name,
      'color': color.value.toString(),
      'playerUID': playerUID,
      'isSecondarySet': isSecondarySet,
    };
  }

  @override
  String toString() {
    return json.encode(data());
  }
}
