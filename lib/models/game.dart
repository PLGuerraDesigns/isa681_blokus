import 'package:blokus/models/board.dart';
import 'package:blokus/models/piece_bank.dart';
import 'package:flutter/material.dart';

class BlokusGame extends StatefulWidget {
  const BlokusGame({super.key});

  @override
  State<BlokusGame> createState() => BlokusGameState();
}

class BlokusGameState extends State<BlokusGame> {
  List<PieceBank> player1Bank = const [
    PieceBank(pieceColor: Colors.blue),
    PieceBank(pieceColor: Colors.yellow)
  ];

  List<PieceBank> player2Bank = const [
    PieceBank(pieceColor: Colors.green),
    PieceBank(pieceColor: Colors.red)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blokus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (Widget playerPieceBank in player1Bank)
                    Expanded(
                      child: playerPieceBank,
                    ),
                ],
              ),
            ),
            const AspectRatio(
              aspectRatio: 1,
              child: Board(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (Widget playerPieceBank in player2Bank)
                    Expanded(
                      child: playerPieceBank,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
