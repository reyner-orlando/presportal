// lib/main.dart

import 'package:flutter/material.dart';
import 'pages/HomeWrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      // Judul yang akan muncul di task manager atau saat di web
      title: 'President University Student Portal',

      // Hapus banner "DEBUG" di pojok kanan atas
      debugShowCheckedModeBanner: false,

      // Tema Aplikasi
      theme: ThemeData(
        // Skema warna utama
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1e40af), // Warna biru tua (Primary Color)
        ),
        useMaterial3: true,
      ),

      // Tentukan halaman pertama yang akan muncul
      home: const HomeWrapper(), // <-- Widget DashboardScreen dipanggil di sini!
    );
  }
}