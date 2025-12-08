import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'RoomBookingPage.dart';
import 'AdminPage.dart';
import 'ProfilePage.dart';

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

  bool get _isAdmin => widget.userRole == 'Admin';

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
    final List<Widget> pages = [
      HomePage(
        userName: widget.userName,
        userId: widget.userId,
        userRole: widget.userRole,
      ),
      RoomBookingPage(
        userId: widget.userId,     // Kirim ID Briant
        userName: widget.userName, // Kirim Nama Briant
      ),
    ];
    if (_isAdmin) {
      pages.add(const AdminPage());
    }

    pages.add(
        ProfilePage(userId: widget.userId) // Kirim userId ke ProfilePage
    );

    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        icon: _buildCircleIcon(Icons.home, isSelected: _currentIndex == 0),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: _buildCircleIcon(Icons.meeting_room, isSelected: _currentIndex == 1),
        label: "Rooms",
      ),
    ];

    if (_isAdmin) {
      navItems.add(
        BottomNavigationBarItem(
          icon: _buildCircleIcon(Icons.admin_panel_settings, isSelected: _currentIndex == 2),
          label: "Admin",
        ),
      );
    }

    int profileIndex = _isAdmin ? 3 : 2;
    navItems.add(
      BottomNavigationBarItem(
        icon: _buildCircleIcon(Icons.person, isSelected: _currentIndex == profileIndex),
        label: "Profile",
      ),
    );



    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed, // Penting agar label tidak geser jika > 3 item
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24), // Ukuran diperbaiki agar tidak terlalu kecil (10 kekecilan)
        showUnselectedLabels: true,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        enableFeedback: true,
        items: navItems, // Gunakan list dinamis yang kita buat di atas
        // Tambahan penting
      ),
    );
  }
}
