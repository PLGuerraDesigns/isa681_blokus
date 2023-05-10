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
    int initialColumnIndex = -1;

    List<List<int>> pieceIndexRepresentation =
        _getRotatedPieceIndexRepresentation(
            piece.shape.indexRepresentation, piece.quarterTurns);

    pieceIndexRepresentation.removeWhere((columns) => !columns.contains(1));

    int piecePositionOffset = _piecePositionOffset(pieceIndexRepresentation);

    try {
      for (List<int> columns in pieceIndexRepresentation) {
        initialColumnIndex = index ~/ 20;
        for (int value in columns) {
          if (value == 1) {
            // Ensure the cells are occupied or the piece doesn't wrap around
            if (_boardCells[index + piecePositionOffset].isOccupied() ||
                (index ~/ 20 != initialColumnIndex)) {
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
        _getRotatedPieceIndexRepresentation(
            piece.shape.indexRepresentation, piece.quarterTurns);

    pieceIndexRepresentation.removeWhere((columns) => !columns.contains(1));

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

  List<List<int>> _getRotatedPieceIndexRepresentation(
      List<List<int>> pieceIndexRepresentation, int quarterTurns) {
    int size = pieceIndexRepresentation.length;
    List<List<int>> rotatedPiece =
        List.generate(size, (_) => List.filled(size, 0));
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        switch (quarterTurns % 4) {
          case 0:
            rotatedPiece[i][j] = pieceIndexRepresentation[i][j];
            break;
          case 1:
            rotatedPiece[i][j] = pieceIndexRepresentation[j][size - i - 1];
            break;
          case 2:
            rotatedPiece[i][j] =
                pieceIndexRepresentation[size - i - 1][size - j - 1];
            break;
          case 3:
            rotatedPiece[i][j] = pieceIndexRepresentation[size - j - 1][i];
            break;
        }
      }
    }
    return rotatedPiece;
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
