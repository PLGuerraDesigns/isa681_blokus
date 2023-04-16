import 'package:blokus/models/cell.dart';
import 'package:flutter/material.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  BoardState createState() => BoardState();
}

class BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.all(20),
      child: Container(
        color: Colors.white,
        child: GridView.count(
          padding: const EdgeInsets.all(1),
          crossAxisCount: 20,
          children: List.generate(
              400,
              (index) => const Cell(
                    boardCell: true,
                  )),
        ),
      ),
    );
  }
}
