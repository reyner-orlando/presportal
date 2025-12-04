import 'package:flutter/material.dart';
import 'RoomBookingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HomeWrapper.dart';
// Ganti dengan paket ikon yang Anda gunakan (misalnya: 'package:flutter_feather_icons/flutter_feather_icons.dart')
// Untuk contoh ini, saya akan menggunakan ikon dari Material Icons.

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
  String studentId = "001202400087"; // id kamu tetap

  List<Map<String, dynamic>> get quickAccessItems => [
    {'title': 'Schedule', 'icon': Icons.calendar_today, 'color': Colors.blue},
    {'title': 'Grades', 'icon': Icons.emoji_events, 'color': Colors.orange},
    {
      'title': 'Book Room',
      'icon': Icons.door_front_door,
      'color': Colors.green,

      // SEKARANG INI AMAN DILAKUKAN:
      'route': RoomBookingPage(
          userId: widget.userId,
          userName: widget.userName
      )
    },
    {'title': 'Profile', 'icon': Icons.person, 'color': Colors.blue},
  ];

  final List<Map<String, dynamic>> todayClasses = const [
    {
      'name': 'Data Structures',
      'lecturer': 'Dr. Smith',
      'time': '09:00 AM',
      'room': 'A-301'
    },
    {
      'name': 'Database Systems',
      'lecturer': 'Dr. Johnson',
      'time': '11:00 AM',
      'room': 'B-205'
    },
    {
      'name': 'Web Development',
      'lecturer': 'Prof. Wilson',
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

  Future<void> fetchStudentData() async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    if (doc.exists) {
      setState(() {
        studentName = doc['name'];
        gpa = doc['gpa'].toString();
        credits = doc['credits'].toString();
        courses = doc['courses'].toString();
      });
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
      body: SingleChildScrollView(
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
    );
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.userName}!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: foregroundPrimaryColor,
                    ),
                  ),
                  Text(
                    'Student ID: ${widget.userId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: foregroundPrimaryColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                    Icons.notifications_none, color: foregroundPrimaryColor,
                    size: 24),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Statistik (GPA, SKS, Mata Kuliah)
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