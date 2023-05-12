import 'package:blokus/models/player.dart';
import 'package:blokus/models/room.dart';
import 'package:blokus/widgets/player_avatar.dart';
import 'package:blokus/widgets/room_join_button.dart';
import 'package:flutter/material.dart';

class RoomListView extends StatelessWidget {
  const RoomListView({
    super.key,
    required this.rooms,
    required this.joinRoomCallback,
    required this.leaveRoomCallback,
    required this.selectedRoomID,
    required this.loading,
  });
  final List<Room> rooms;
  final String selectedRoomID;
  final Function(String) joinRoomCallback;
  final Function() leaveRoomCallback;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    Widget roomListTile(Room room) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.only(
          top: 8,
          bottom: 4,
          left: 8,
          right: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(0),
          minVerticalPadding: 0,
          title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 100),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    room.name,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Players (${room.players.length}/4)',
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
          ),
          subtitle: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 175),
            child: Row(
              children: [
                const SizedBox(width: 8),
                for (Player player in room.players)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: PlayerAvatar(
                        player: player,
                        transparentBackground: false,
                      )),
                const Spacer(),
                RoomJoinButton(
                  room: room,
                  joinRoomCallback: joinRoomCallback,
                  exitRoomCallback: leaveRoomCallback,
                  enabled: selectedRoomID.isEmpty && room.players.length < 4,
                  isSelected: room.id == selectedRoomID,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[400]!),
          color: Colors.grey[200]),
      child: loading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : rooms.isEmpty
              ? const Center(
                  child: Text(
                    "NO ACTIVE ROOMS\n\nCreate one to get started.",
                    style: TextStyle(color: Colors.black45),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return roomListTile(rooms[index]);
                  },
                ),
    );
  }
}
