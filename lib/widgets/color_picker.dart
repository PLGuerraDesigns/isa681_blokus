import 'package:flutter/material.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.colorSelectionCallback,
    required this.playerSelection,
    required this.opponentSelection,
  });
  final Function(Color) colorSelectionCallback;
  final List<Color> playerSelection;
  final List<Color> opponentSelection;
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    Widget colorOption(
      Color color,
    ) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            widget.colorSelectionCallback(color);
          },
          child: CircleAvatar(
            backgroundColor: color.withOpacity(
                widget.opponentSelection.contains(color) ? 0.25 : 1),
            child: Icon(
              Icons.check,
              color: Colors.white
                  .withOpacity(widget.playerSelection.contains(color) ? 1 : 0),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Select a color:"),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            colorOption(Colors.blue),
            colorOption(Colors.red),
            colorOption(Colors.green),
            colorOption(Colors.amber),
          ],
        ),
      ],
    );
  }
}
