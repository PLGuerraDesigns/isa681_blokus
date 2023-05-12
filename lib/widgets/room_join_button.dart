import 'package:blokus/models/room.dart';
import 'package:flutter/material.dart';

class RoomJoinButton extends StatelessWidget {
  const RoomJoinButton({
    super.key,
    required this.room,
    required this.joinRoomCallback,
    required this.exitRoomCallback,
    required this.enabled,
    required this.isSelected,
  });
  final Room room;
  final Function(String) joinRoomCallback;
  final Function() exitRoomCallback;
  final bool enabled;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelected
          ? () => exitRoomCallback()
          : enabled
              ? () => joinRoomCallback(room.id)
              : null,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red
              : Colors.green.withOpacity(enabled ? 1 : 0.5),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            isSelected ? Icons.person_remove : Icons.person_add,
            color: Colors.white,
          ),
          Text(
            isSelected ? "LEAVE" : "JOIN",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ]),
      ),
    );
  }
}
