import 'dart:convert';

import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/cell.dart';
import 'package:blokus/models/piece.dart';
<<<<<<< HEAD
=======
import 'package:blokus/widgets/custom_snackbar.dart';
>>>>>>> dev-plg
import 'package:flutter/material.dart';

class Board {
  List<Cell> _boardCells = [];
  final Map<String, dynamic> _configuration = {};
  int numberOfColumns;

  String get configuration {
    return json.encode(_configuration);
  }

  Board({required this.numberOfColumns}) {
<<<<<<< HEAD
    for (int x = 0; x < numberOfColumns * numberOfColumns; x++) {
      _boardCells.add(Cell(id: x, color: Colors.grey[300]!));
    }
=======
    resetBoard();
>>>>>>> dev-plg
  }

  Cell getCell(int id) {
    return _boardCells[id];
  }

<<<<<<< HEAD
  bool validPiecePlacement({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;
    try {
      for (List<int> columns in piece.shape.indexRepresentation) {
        for (int value in columns) {
          if (value == 1) {
            if (!_boardCells[index].isOccupied()) {
=======
  bool validPiecePlacement({
    required int targetCellID,
    required Piece piece,
    required BuildContext context,
  }) {
    int index = targetCellID;
    int columnIterator = 0;
    int initialColumnIndex = 0;
    int currentColumnIndex = 0;
    bool playingFirstPiece =
        _boardCells.where((cell) => cell.color == piece.color).isEmpty;

    if (playingFirstPiece && !_firstPieceInCorner(targetCellID, piece)) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackbar().floatingMessage(
          context,
          "The first piece played must cover the color's corner square.",
          Colors.red,
        ),
      );
      return false;
    }

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
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar().floatingMessage(
                    context, "The piece doesn't fit.", Colors.red),
              );
>>>>>>> dev-plg
              return false;
            }
          }
          index++;
        }
        columnIterator += numberOfColumns;
        index = targetCellID + columnIterator;
      }
<<<<<<< HEAD
=======
      if (!playingFirstPiece) {
        return _diagonalMatchOnly(context, targetCellID, piece);
      }
>>>>>>> dev-plg
      return true;
    } on RangeError {
      return false;
    }
  }

<<<<<<< HEAD
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
=======
  bool _firstPieceInCorner(int targetCellID, Piece piece) {
    List<int> pieceAsBoardCellIndexList =
        _getPieceAsBoardCellIndexList(targetCellID, piece);

    if (piece.color.value == Colors.blue.value &&
        pieceAsBoardCellIndexList.contains(_boardCells.first.id)) {
      return true;
    } else if (piece.color.value == Colors.red.value &&
        pieceAsBoardCellIndexList
            .contains(_boardCells[_boardCells.length - numberOfColumns].id)) {
      return true;
    } else if (piece.color.value == Colors.amber[600]!.value &&
        pieceAsBoardCellIndexList
            .contains(_boardCells[numberOfColumns].id - 1)) {
      return true;
    } else if (piece.color.value == Colors.green.value &&
        pieceAsBoardCellIndexList.contains(_boardCells.last.id)) {
      return true;
    }
    return false;
  }

  bool _diagonalMatchOnly(BuildContext context, int targetCellID, Piece piece) {
    List<int> pieceAsBoardCellIndexList =
        _getPieceAsBoardCellIndexList(targetCellID, piece);
    for (int index in pieceAsBoardCellIndexList) {
      // Ensure perpendicular pieces don't match
      for (int indexOffset in [-20, -1, 1, 20]) {
        if (cellOccupiedByColor(index + indexOffset, piece.color)) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackbar().floatingMessage(
              context,
              "Pieces of the same color must NOT touch along a side.",
              Colors.red,
            ),
          );
          return false;
        }
      }

      // Ensure at least one diagonal piece matches
      for (int indexOffset in [-21, -19, 19, 21]) {
        if (cellOccupiedByColor(index + indexOffset, piece.color)) {
          return true;
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackbar().floatingMessage(
        context,
        "The piece must touch at least one corner of another same-colored piece.",
        Colors.red,
      ),
    );
    return false;
  }

  bool cellOccupiedByColor(int cellID, Color color) {
    try {
      if (_boardCells[cellID].color.value == color.value) {
        return true;
      }
      return false;
    } on RangeError {
      return false;
    }
  }

  List<int> _getPieceAsBoardCellIndexList(
    int targetCellID,
    Piece piece,
  ) {
    List<List<int>> pieceIndexRepresentation =
        piece.shape.getRotatedPieceIndexRep(piece.quarterTurns);

    int piecePositionOffset = _piecePositionOffset(pieceIndexRepresentation);

    int columnIndex = 0;
    int rowIndex = 0;
    List<int> pieceAsBoardCellIndexList = [];
    for (var column in pieceIndexRepresentation) {
      for (int index in column) {
        if (index == 1) {
          pieceIndexRepresentation[columnIndex][rowIndex] =
              targetCellID + rowIndex + piecePositionOffset;
          pieceAsBoardCellIndexList
              .add(targetCellID + rowIndex + piecePositionOffset);
        }
        rowIndex++;
      }
      targetCellID += 20;
      columnIndex++;
      rowIndex = 0;
    }
    return pieceAsBoardCellIndexList;
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
>>>>>>> dev-plg

      _updateCells(targetCellID: int.parse(element.key), piece: piece);
    }
  }

  void addPiece({required int targetCellID, required Piece piece}) {
<<<<<<< HEAD
    _configuration[targetCellID.toString()] = {
      'color': piece.color.value,
      'piece': piece.shape.name,
      'playerID': piece.playerUID,
    };
=======
    _configuration[targetCellID.toString()] = piece.data();
>>>>>>> dev-plg
    _updateCells(targetCellID: targetCellID, piece: piece);
  }

  void _updateCells({required int targetCellID, required Piece piece}) {
    int index = targetCellID;
    int columnIterator = 0;
<<<<<<< HEAD
    for (List<int> columns in piece.shape.indexRepresentation) {
      for (int value in columns) {
        if (value == 1) {
          _boardCells[index] = Cell(
              id: index, color: piece.color, occupiedPlayerID: piece.playerUID);
=======

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
>>>>>>> dev-plg
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

<<<<<<< HEAD
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

=======
>>>>>>> dev-plg
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
