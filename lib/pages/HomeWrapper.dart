import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'RoomBookingPage.dart';

class HomeWrapper extends StatefulWidget {
  final String userRole;
  final String userName;
  final String userId;

  const HomeWrapper({
    super.key,
    required this.userName,
    required this.userId,
    required this.userRole,
  });

  @override
  _HomeWrapperState createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;
  Widget _buildCircleIcon(IconData icon, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey.shade600,
        size: 24,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(
        userName: widget.userName,
        userId: widget.userId,
        userRole: widget.userRole,
      ),
      RoomBookingPage(
        userId: widget.userId,     // Kirim ID Briant
        userName: widget.userName, // Kirim Nama Briant
      ),
      const Scaffold(body: Center(child: Text("Halaman Profil"))),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },

        // Tambahan penting
        selectedIconTheme: IconThemeData(size: 28),
        unselectedIconTheme: IconThemeData(size: 24),

        // Ripple hanya di icon
        enableFeedback: true,

        items: [
          BottomNavigationBarItem(
            icon: _buildCircleIcon(
              Icons.home,
              isSelected: _currentIndex == 0,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(
              Icons.meeting_room,
              isSelected: _currentIndex == 1,
            ),
            label: "Rooms",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(
              Icons.person,
              isSelected: _currentIndex == 2,
            ),
            label: "Profile",
          ),
        ],
      ),

    );
  }
}
