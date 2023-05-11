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
    resetBoard();
  }

  Cell getCell(int id) {
    return _boardCells[id];
  }

  bool validPiecePlacement({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;
    int initialColumnIndex = 0;
    int currentColumnIndex = 0;

    List<List<int>> pieceIndexRepresentation =
        piece.shape.getRotatedPieceIndexRep(piece.quarterTurns);

    int piecePositionOffset = _piecePositionOffset(pieceIndexRepresentation);

    try {
      for (List<int> columns in pieceIndexRepresentation) {
        if ((piece.quarterTurns == 2 || piece.quarterTurns == 3) &&
            targetCellID % 20 > 10) {
          initialColumnIndex = (index + piecePositionOffset) ~/ 20;
        } else {
          initialColumnIndex = (index) ~/ 20;
        }
        for (int value in columns) {
          if (value == 1) {
            if ((piece.quarterTurns == 2 || piece.quarterTurns == 3) &&
                targetCellID % 20 > 10) {
              currentColumnIndex = (index + piecePositionOffset) ~/ 20;
            } else {
              currentColumnIndex = (index) ~/ 20;
            }
            // Ensure the cells are occupied or the piece doesn't wrap around
            if (_boardCells[index + piecePositionOffset].isOccupied() ||
                initialColumnIndex != currentColumnIndex) {
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

  int _piecePositionOffset(List<List<int>> pieceIndexRepresentation) {
    int rowIterator = 0;
    int columnOffset = 0;
    int rowOffset = 0;
    int columnIterator = 0;

    while (pieceIndexRepresentation[columnIterator][rowIterator] == 0) {
      columnOffset -= 20;
      columnIterator++;
      if (columnIterator == pieceIndexRepresentation.length) {
        columnOffset = 0;
        columnIterator = 0;
        rowOffset--;
        rowIterator++;
      }
    }

    return columnOffset + rowOffset;
  }

  void setUpBoard(String boardConfigurationString) {
    Map<String, dynamic> boardConfiguration =
        jsonDecode(boardConfigurationString);

    for (var element in boardConfiguration.entries) {
      Piece piece = Piece(
        playerUID: element.value['playerUID'],
        color: Color(int.parse(element.value['colorValue'])),
        shape: PieceShape.values
            .where((piece) => piece.name == element.value['shape'])
            .first,
        isSecondarySet: element.value['isSecondarySet'],
        quarterTurns: element.value['quarterTurns'],
      );

      _updateCells(targetCellID: int.parse(element.key), piece: piece);
    }
  }

  void addPiece({required int targetCellID, required Piece piece}) {
    _configuration[targetCellID.toString()] = piece.data();
    _updateCells(targetCellID: targetCellID, piece: piece);
  }

  void _updateCells({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;

    List<List<int>> pieceIndexRepresentation =
        piece.shape.getRotatedPieceIndexRep(piece.quarterTurns);

    int piecePositionOffset = _piecePositionOffset(pieceIndexRepresentation);

    for (List<int> columns in pieceIndexRepresentation) {
      for (int value in columns) {
        if (value == 1) {
          _boardCells[index + piecePositionOffset] = Cell(
              id: index + piecePositionOffset,
              color: piece.color,
              occupiedPlayerID: piece.playerUID);
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
