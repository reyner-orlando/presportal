// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Import halaman
import 'package:projectwmp/pages/LoginPage.dart';
import 'pages/HomeWrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'President University Student Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1e40af),
        ),
        useMaterial3: true,
      ),

      // LOGIKA UTAMA: AUTH GATE
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          // 1. Loading Cek Status Login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          // 2. Jika User Terdeteksi Login (Ada Datanya)
          if (snapshot.hasData) {
            final User authUser = snapshot.data!;

            // --------------------------------------------------
            // A. LOGIKA AUTO LOGOUT (CEK WAKTU)
            // --------------------------------------------------
            final lastSignIn = authUser.metadata.lastSignInTime;

            if (lastSignIn != null) {
              final difference = DateTime.now().difference(lastSignIn);

              // Ganti .inMinutes dengan .inHours jika sudah siap rilis (misal 1 Jam)
              if (difference.inMinutes >= 60) {

                // Logout Paksa
                Future.microtask(() => FirebaseAuth.instance.signOut());

                // Tampilkan Login
                return const LoginPage();
              }
            }
            // --------------------------------------------------

            // --------------------------------------------------
            // B. AMBIL DATA PROFIL (JIKA WAKTU AMAN)
            // --------------------------------------------------
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('user_id', isEqualTo: authUser.uid)
                  .limit(1)
                  .get(),

              builder: (context, userSnapshot) {
                // Loading saat ambil data Firestore
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                // Data ditemukan
                if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
                  var userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                  var documentId = userSnapshot.data!.docs.first.id;

                  return HomeWrapper(
                    userName: userData['full_name'] ?? 'Mahasiswa',
                    userId: documentId,
                    userRole: userData['role'] ?? 'Student',
                  );
                }

                // Data Firestore tidak ditemukan (User hantu) -> Balik ke Login
                return const LoginPage();
              },
            );
          }

          // 3. Jika Belum Login (snapshot tidak punya data)
          return const LoginPage();
        },
      ),
    );
  }
}