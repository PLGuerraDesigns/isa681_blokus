import 'package:blokus/constants/piece_variations.dart';

/// Stores the different piece shapes.
enum PieceShape {
  i1,
  i2,
  i3,
  i4,
  i5,
  l5,
  y,
  n,
  v3,
  u,
  v5,
  z5,
  x,
  t5,
  w,
  p,
  f,
  o4,
  l4,
  t4,
  z4
}

extension PieceShapeTypeExtension on PieceShape {
  List<List<int>> get indexRepresentation {
    switch (this) {
      case PieceShape.i1:
        return PieceIndexRepresentation.i1;
      case PieceShape.i2:
        return PieceIndexRepresentation.i2;
      case PieceShape.i3:
        return PieceIndexRepresentation.i3;
      case PieceShape.i4:
        return PieceIndexRepresentation.i4;
      case PieceShape.i5:
        return PieceIndexRepresentation.i5;
      case PieceShape.l5:
        return PieceIndexRepresentation.l5;
      case PieceShape.y:
        return PieceIndexRepresentation.y;
      case PieceShape.n:
        return PieceIndexRepresentation.n;
      case PieceShape.v3:
        return PieceIndexRepresentation.v3;
      case PieceShape.u:
        return PieceIndexRepresentation.u;
      case PieceShape.v5:
        return PieceIndexRepresentation.v5;
      case PieceShape.z5:
        return PieceIndexRepresentation.z5;
      case PieceShape.x:
        return PieceIndexRepresentation.x;
      case PieceShape.t5:
        return PieceIndexRepresentation.t5;
      case PieceShape.w:
        return PieceIndexRepresentation.w;
      case PieceShape.p:
        return PieceIndexRepresentation.p;
      case PieceShape.f:
        return PieceIndexRepresentation.f;
      case PieceShape.o4:
        return PieceIndexRepresentation.o4;
      case PieceShape.l4:
        return PieceIndexRepresentation.l4;
      case PieceShape.t4:
        return PieceIndexRepresentation.t4;
      case PieceShape.z4:
        return PieceIndexRepresentation.z4;
    }
  }

  List<List<int>> getRotatedPieceIndexRep(int quarterTurns) {
    int size = indexRepresentation.length;

    List<List<int>> rotatedPiece =
        List.generate(size, (_) => List.filled(size, 0));

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        switch (quarterTurns % 4) {
          case 0:
            rotatedPiece[i][j] = indexRepresentation[i][j];
            break;
          case 1:
            rotatedPiece[i][j] = indexRepresentation[j][size - i - 1];
            break;
          case 2:
            rotatedPiece[i][j] =
                indexRepresentation[size - i - 1][size - j - 1];
            break;
          case 3:
            rotatedPiece[i][j] = indexRepresentation[size - j - 1][i];
            break;
        }
      }
    }

    // Remove empty columns
    rotatedPiece.removeWhere((columns) => !columns.contains(1));

    return rotatedPiece;
  }

  bool are2DListsEqual(List<List<int>> a, List<List<int>> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) {
        return false;
      }
      for (int j = 0; j < a[i].length; j++) {
        if (a[i][j] != b[i][j]) {
          return false;
        }
      }
    }
    return true;
  }
}
