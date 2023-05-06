import 'dart:convert';

import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/cell.dart';
import 'package:blokus/models/piece.dart';
import 'package:flutter/material.dart';

class Board {
  List<Cell> _boardCells = [];
  final Map<String, dynamic> _configuration = {};
  int numberOfColumns;

  String get configuration {
    return json.encode(_configuration);
  }

  Board({required this.numberOfColumns}) {
    for (int x = 0; x < numberOfColumns * numberOfColumns; x++) {
      _boardCells.add(Cell(id: x, color: Colors.grey[300]!));
    }
  }

  Cell getCell(int id) {
    return _boardCells[id];
  }

  bool validPiecePlacement({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;
    try {
      for (List<int> columns in piece.shape.indexRepresentation) {
        for (int value in columns) {
          if (value == 1) {
            if (!_boardCells[index].isOccupied()) {
              return false;
            }
          }
          index++;
        }
        columnIterator += numberOfColumns;
        index = targetCellID + columnIterator;
      }
      return true;
    } on RangeError {
      return false;
    }
  }

  void setUpBoard(String boardConfigurationString) {
    Map<dynamic, dynamic> boardConfiguration =
        jsonDecode(boardConfigurationString);

    Piece piece;
    for (var element in boardConfiguration.entries) {
      piece = Piece(
          color: Color(element.value['color'] as int),
          shape: PieceShape.values
              .where((piece) => piece.name == element.value['piece'])
              .first,
          playerUID: element.value['playerID']);

      _updateCells(targetCellID: int.parse(element.key), piece: piece);
    }
  }

  void addPiece({required int targetCellID, required Piece piece}) {
    _configuration[targetCellID.toString()] = {
      'color': piece.color.value,
      'piece': piece.shape.name,
      'playerID': piece.playerUID,
    };
    _updateCells(targetCellID: targetCellID, piece: piece);
  }

  void _updateCells({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;
    for (List<int> columns in piece.shape.indexRepresentation) {
      for (int value in columns) {
        if (value == 1) {
          _boardCells[index] = Cell(
              id: index, color: piece.color, occupiedPlayerID: piece.playerUID);
        }
        index++;
      }
      columnIterator += numberOfColumns;
      index = targetCellID + columnIterator;
    }
  }

  void resetBoard() {
    _boardCells = [];
    for (int x = 0; x < numberOfColumns * numberOfColumns; x++) {
      _boardCells.add(Cell(id: x, color: Colors.grey[300]!));
    }
  }

  String printOccupied() {
    String text = '';
    int index = 0;
    for (Cell cell in _boardCells) {
      if (cell.isOccupied()) {
        text += '$index: ${cell.isOccupied()}\n';
      }
      index++;
    }

    return text;
  }

  @override
  String toString() {
    String text = '';
    int index = 0;
    for (Cell cell in _boardCells) {
      text += '$index: ${cell.isOccupied()}\n';
      index++;
    }

    return text;
  }
}
