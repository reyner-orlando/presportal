import 'package:flutter/material.dart';
import '../services/room_service.dart';
import '../widgets/date_view.dart';
import '../widgets/category_view.dart';
import '../widgets/room_card.dart';
import '../models/room.dart';
import '../services/booking_service.dart';

const Color accentColor = Color(0xFFfb8c00);
const Color secondaryColor = Color(0xFF8b5cf6);
const Color foregroundAccentColor = Colors.white;

final categories = ["Classroom", "Laboratory", "Auditorium", "Venue"];
final roomService = RoomService();
final bookingService = BookingService();

class RoomBookingPage extends StatefulWidget {
  const RoomBookingPage({super.key});

  @override
  State<RoomBookingPage> createState() => _RoomBookingPageState();
}

class _RoomBookingPageState extends State<RoomBookingPage> {
  int selectedTabIndex = 0;
  DateTime selectedDay = DateTime.now();
  String selectedCategory = "Classroom";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Builder(
              builder: (_) {
                if (selectedTabIndex == 0) {
                  return StreamBuilder<List<Room>>(
                    stream: roomService.getRooms(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final rooms = snapshot.data!;
                      return ListView(
                        padding: const EdgeInsets.all(16),
                        children: rooms.map((r) => RoomCard(
                          room: r,
                          onBooking: () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Booking ${r.name} ...'))),
                        )).toList(),
                      );
                    },
                  );
                } else if (selectedTabIndex == 1) {
                  return DateView(
                    selectedDay: selectedDay,
                    onDaySelected: (day) => setState(() => selectedDay = day),
                    bookService: bookingService,
                  );
                } else {
                  return CategoryView(
                    selectedCategory: selectedCategory,
                    onCategoryChanged: (cat) => setState(() => selectedCategory = cat),
                    roomService: roomService,
                    categories: categories,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColor.withOpacity(0.9)],
        ),
      ),
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Room Booking', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: foregroundAccentColor)),
          const SizedBox(height: 4),
          Text('Reserve study and meeting spaces', style: TextStyle(fontSize: 14, color: foregroundAccentColor.withOpacity(0.8))),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTabButton('List', 0),
              const SizedBox(width: 8),
              _buildTabButton('By Date', 1),
              const SizedBox(width: 8),
              _buildTabButton('Category', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool isSelected = selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedTabIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? secondaryColor : foregroundAccentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : foregroundAccentColor)),
        ),
      ),
    );
  }
}
