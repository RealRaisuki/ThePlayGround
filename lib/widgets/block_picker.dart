import 'package:flutter/material.dart';

class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker(
      {super.key, required this.pickerColor, required this.onColorChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
        Colors.lightBlue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lightGreen,
        Colors.lime,
        Colors.yellow,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.brown,
        Colors.grey,
        Colors.blueGrey,
        Colors.black,
      ]
          .map((color) => GestureDetector(
                onTap: () => onColorChanged(color),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 20,
                ),
              ))
          .toList(),
    );
  }
}
