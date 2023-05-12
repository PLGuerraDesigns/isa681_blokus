import 'dart:math';

import 'package:blokus/constants/custom_enums.dart';
import 'package:blokus/models/piece.dart';
import 'package:blokus/widgets/piece_view.dart';
import 'package:flutter/material.dart';

class GMUBlokusBackground extends StatelessWidget {
  const GMUBlokusBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 0.5,
          child: Image.asset(
            'assets/images/gmu_logo_cropped.png',
            alignment: Alignment.bottomLeft,
          ),
        ),
        Opacity(
          opacity: 0.08,
          child: Transform.scale(
            scale: 2,
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateZ(0.5)
                ..rotateX(-0.5)
                ..rotateY(0.5),
              alignment: Alignment.center,
              child: GridView.custom(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  crossAxisCount: 12,
                ),
                physics: const NeverScrollableScrollPhysics(),
                childrenDelegate: SliverChildListDelegate(gamePieces()),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  List<Widget> gamePieces() {
    List<Color> colors = [
      Colors.blue,
      Colors.amber[600]!,
      Colors.red,
      Colors.green,
    ];

    final List<Widget> gamePieces = [];

    for (int x = 0; x < 5; x++) {
      gamePieces.addAll(PieceShape.values
          .map((e) => PieceView(
                piece: Piece(
                    color: colors[Random().nextInt(3)],
                    shape: e,
                    playerUID: ''),
              ))
          .toList());
    }

    return gamePieces;
  }
}
