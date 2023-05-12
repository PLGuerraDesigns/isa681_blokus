import 'package:flutter/material.dart';

class Cell {
  Color color;
  late String occupiedPlayerID;
  int id;

  Cell({required this.id, required this.color, String? occupiedPlayerID}) {
    this.occupiedPlayerID = occupiedPlayerID ?? '';
  }

  bool isOccupied() {
    return occupiedPlayerID.isNotEmpty;
  }
}
