import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';             // Pastikan import Login Page
import '../widgets/user_bookings_history.dart';  // Pastikan import Widget History Booking user

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Data user default
  String fullName = "Loading...";
  String email = "-";
  String role = "-";
  String phone = "-";
  String profileImageUrl = "https://ui-avatars.com/api/?name=User&background=random"; // Placeholder awal

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // 1. Ambil Data User Terbaru dari Firestore
  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          fullName = data['full_name'] ?? 'User';
          email = data['email'] ?? '-';
          role = data['role'] ?? 'Student';
          phone = data['phone'] ?? '-'; // Pastikan field 'phone' ada di database, atau kosongkan

          // Logic Gambar: Kalau ada URL pakai itu, kalau tidak pakai API inisial nama
          if (data['profile_image_url'] != null && data['profile_image_url'].toString().isNotEmpty) {
            profileImageUrl = data['profile_image_url'];
          } else {
            profileImageUrl = "https://ui-avatars.com/api/?name=${fullName.replaceAll(' ', '+')}&background=0D47A1&color=fff";
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      setState(() => isLoading = false);
    }
  }

  // 2. Fungsi Logout
  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;
              // Kembali ke Login dan hapus semua history page
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    const Color primaryColor = Color(0xFF1e40af); // Biru Tua

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Background abu sangat muda
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Background Biru
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
                // Judul Halaman
                const Positioned(
                  top: 50,
                  child: Text(
                    "My Profile",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Foto Profil (Overlapping)
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Jarak kompensasi foto profil

            // --- NAMA & ROLE ---
            Text(fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[100]!)
              ),
              child: Text(role, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
            ),

            const SizedBox(height: 20),

            // --- MENU INFO PRIBADI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(Icons.email_outlined, "Email", email),
                  _buildInfoCard(Icons.badge_outlined, "Student ID", widget.userId),
                  _buildInfoCard(Icons.phone_iphone, "Phone", phone),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU SETTINGS & ACTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Account Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)]
                    ),
                    child: Column(
                      children: [
                        // LINK KE BOOKING HISTORY
                        _buildMenuTile(
                            icon: Icons.history_edu,
                            color: Colors.orange,
                            title: "My Booking History",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UserBookingHistory(userId: widget.userId)),
                              );
                            }
                        ),
                        const Divider(height: 1, indent: 50),

                        // EDIT PROFILE (Placeholder)
                        _buildMenuTile(
                            icon: Icons.edit_outlined,
                            color: Colors.blue,
                            title: "Edit Profile",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Edit Profile feature coming soon!")));
                            }
                        ),
                        const Divider(height: 1, indent: 50),

                        // LOGOUT
                        _buildMenuTile(
                            icon: Icons.logout,
                            color: Colors.red,
                            title: "Logout",
                            onTap: _handleLogout,
                            isDanger: true
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text("App Version 1.0.0", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Kartu Info Kecil (Email, ID, HP)
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
              child: Icon(icon, color: Colors.blue[700], size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget Helper: Menu List Tile
  Widget _buildMenuTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red : Colors.black87
      )),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}