import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/room_service.dart';
import 'room_card.dart';

class CategoryView extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final RoomService roomService;
  final List<String> categories;

  const CategoryView({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.roomService,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
            onChanged: (value) => onCategoryChanged(value!),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Room>>(
            stream: roomService.getRooms(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final filtered = snapshot.data!.where((r) => r.location.contains(selectedCategory)).toList();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: filtered.map((room) => RoomCard(
                  room: room,
                  onBooking: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking ${room.name} ...'))),
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
