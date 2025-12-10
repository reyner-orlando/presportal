import 'package:flutter/material.dart';
import 'RoomBookingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan ini
import 'LoginPage.dart'; // Tambahkan ini agar bisa kembali ke Login
import 'ProfilePage.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userId;
  final String userRole;
  const HomePage({
    super.key,
    required this.userName,
    required this.userId,
    required this.userRole,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  // Data palsu untuk mereplikasi tampilan
  String gpa = "-";
  String credits = "-";
  String courses = "-";
  String studentName = "-";
  String studentId = "-"; // id kamu tetap
  String profileImageUrl = "https://picsum.photos/seed/default/200/200"; // Gambar default

  List<Map<String, dynamic>> get quickAccessItems => [
    {'title': 'Schedule', 'icon': Icons.calendar_today, 'color': Colors.blue},
    {'title': 'Grades', 'icon': Icons.emoji_events, 'color': Colors.orange},
    {
      'title': 'Book Room',
      'icon': Icons.door_front_door,
      'color': Colors.green,

      'route': RoomBookingPage(
          userId: widget.userId,
          userName: widget.userName
      )
    },
    {'title': 'Profile', 'icon': Icons.person, 'color': Colors.blue, 'route': ProfilePage(userId: widget.userId)},
  ];

  final List<Map<String, dynamic>> todayClasses = const [
    {
      'name': 'Data Structures and Algorithm',
      'lecturer': 'Nur Hadisukmana',
      'time': '09:00 AM',
      'room': 'A216'
    },
    {
      'name': 'Database Systems',
      'lecturer': 'Ronny Juwono',
      'time': '11:00 AM',
      'room': 'B-205'
    },
    {
      'name': 'Web Development',
      'lecturer': 'William',
      'time': '02:00 PM',
      'room': 'C-104'
    },
  ];

  final List<Map<String, dynamic>> announcements = const [
    {
      'title': 'Midterm Exam Schedule Released',
      'category': 'Academic',
      'time': 'Today'
    },
    {
      'title': 'Campus Library Extended Hours',
      'category': 'Campus',
      'time': 'Yesterday'
    },
    {
      'title': 'Student Council Meeting',
      'category': 'Event',
      'time': '2 days ago'
    },
  ];

  // Fungsi untuk menangani Logout
  Future<void> _handleLogout() async {
    // Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseAuth.instance.signOut();

        // Cek apakah widget masih mounted sebelum navigasi
        if (!mounted) return;

        // Navigasi kembali ke Login Page dan hapus history route sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  Future<void> fetchStudentData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (doc.exists && doc.data() != null) {
        // Ambil data sebagai Map agar aman
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          gpa = (data['gpa'] ?? 0.0).toString();
          credits = (data['credits'] ?? 0).toString();
          courses = (data['courses'] ?? 0).toString();
          if (data['profile_image_url'] != null && data['profile_image_url']
              .toString()
              .isNotEmpty) {
            profileImageUrl = data['profile_image_url'];
          }
        });
      }
    }catch (e) {
      print("Gagal mengambil data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna yang mirip dengan skema Tailwind/Shadcn UI pada kode HTML
    const Color primaryColor = Color(
        0xFF1e40af); // Mirip dengan 'primary' (biru tua)
    const Color foregroundPrimaryColor = Colors.white;
    const Color cardColor = Colors.white;
    const Color mutedColor = Color(0xFFf3f4f6); // Mirip dengan 'muted/50'

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchStudentData, // Panggil fungsi fetch saat ditarik
        color: primaryColor, // Warna loading spinner
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
            // --- Header Bagian Atas ---
              _buildHeader(primaryColor, foregroundPrimaryColor),

            // --- Bagian Utama Konten (Main) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // --- Quick Access ---
                    _buildQuickAccess(primaryColor, cardColor),
                    const SizedBox(height: 24),

                  // --- Today's Classes ---
                    _buildTodayClasses(primaryColor, cardColor, mutedColor),
                    const SizedBox(height: 24),

                  // --- Announcements ---
                    _buildAnnouncements(cardColor, mutedColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Header (Header Berwarna Gradien)
  // Widget untuk Header (Header Berwarna Gradien)
  Widget _buildHeader(Color primaryColor, Color foregroundPrimaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- BARIS UTAMA (PROFILE & ACTION BUTTONS) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // GROUP KIRI: FOTO + TEKS
              Expanded(
                child: Row(
                  children: [
                    // 1. FOTO PROFIL
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: NetworkImage(profileImageUrl),
                        onBackgroundImageError: (exception, stackTrace) {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 2. TEKS NAMA & ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.userName}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: foregroundPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.userRole == 'Student' ? 'Student ID' : 'Lecturer ID'}: ${widget.userId}',
                            style: TextStyle(
                              fontSize: 14,
                              color: foregroundPrimaryColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // GROUP KANAN: ACTIONS
              Row(
                mainAxisSize: MainAxisSize.min, // Agar Row tidak mengambil semua space
                children: [
                  // Icon Notifikasi (Yang lama)
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none,
                      color: foregroundPrimaryColor,
                      size: 28,
                    ),
                    tooltip: 'Notifications',
                  ),

                  // [BARU] Icon Logout
                  IconButton(
                    onPressed: _handleLogout, // Panggil fungsi logout
                    icon: Icon(
                      Icons.logout,
                      color: foregroundPrimaryColor, // Warna putih/sesuai tema header
                      size: 24, // Sedikit lebih kecil dari notif agar seimbang
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- STATISTIK (GPA, CREDITS, COURSES) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(gpa, 'GPA', primaryColor),
              _buildStatCard(credits, 'Credits', primaryColor),
              _buildStatCard(courses, 'Courses', primaryColor),
            ],
          ),
        ],
      ),
    );
  }


  // Widget untuk Kartu Statistik di Header
  Widget _buildStatCard(String value, String label, Color primaryColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          // background:primary-foreground/10
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          // border-primary-foreground/20
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk Akses Cepat (Quick Access)
  Widget _buildQuickAccess(Color primaryColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75, // Untuk mengakomodasi ikon dan teks
          ),
          itemCount: quickAccessItems.length,
          itemBuilder: (context, index) {
            final item = quickAccessItems[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['route']),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        // bg-primary/10 dll
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 24,
                        color: item['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Widget untuk Kelas Hari Ini (Today's Classes)
  Widget _buildTodayClasses(Color primaryColor, Color cardColor,
      Color mutedColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Today's Classes",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Monday, November 15, 2025",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16.0),
            itemCount: todayClasses.length,
            itemBuilder: (context, index) {
              final item = todayClasses[index];
              return Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 16.0, right: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mutedColor, // bg-muted/50
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item['lecturer'] as String,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['time'] as String,
                            style: TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryColor),
                          ),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12,
                                  color: Colors.grey.shade600),
                              const SizedBox(width: 2),
                              Text(
                                item['room'] as String,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget untuk Pengumuman (Announcements)
  Widget _buildAnnouncements(Color cardColor, Color mutedColor) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.campaign, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  "Announcements",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16.0),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              return Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 16.0, right: 16.0),
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            // secondary/10
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.message_outlined, size: 16,
                              color: Colors.orange), // text-secondary
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['category']} • ${item['time']}',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
//   Widget _buildBottomNavigationBar(BuildContext context, Color primaryColor) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
//       ),
//       child: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: primaryColor,
//         unselectedItemColor: Colors.grey.shade600,
//         currentIndex: 0,
//
//         onTap: (index) {
//           if (index == 2) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => RoomBookingPage()),
//             );
//           }else if (index == 0){
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => HomePage()),
//             );
//           }
//         },
//
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: 'Schedule',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.door_front_door),
//             label: 'Rooms',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
//
// }
//
// // // File utama (main.dart) untuk menjalankan aplikasi
// // void main() {
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Student Portal',
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1e40af)),
// //         useMaterial3: true,
// //       ),
// //       home: const HomePage(),
// //     );
// //   }
// // }