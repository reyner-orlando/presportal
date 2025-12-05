import 'package:flutter/material.dart';

const Color mutedColor = Color(0xFFf3f4f6);

class FacilityTag extends StatelessWidget {
  final String text;
  const FacilityTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.check;

    if (text.contains('WiFi')) icon = Icons.wifi;
    else if (text.contains('Projector')) icon = Icons.monitor;
    else if (text.contains('TV Screen')) icon = Icons.tv;
    else if (text.contains('AC')) icon = Icons.ac_unit;
    else if (text.contains('Whiteboard')) icon = Icons.gesture;
    else if (text.contains('Power Outlets')) icon = Icons.power;
    else if (text.contains('LAN Cable')) icon = Icons.lan;
    else if (text.contains('Computer')) icon = Icons.computer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: mutedColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
