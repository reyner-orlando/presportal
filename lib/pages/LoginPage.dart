import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeWrapper.dart'; // Import Dashboard
// import 'RegisterPage.dart'; // Import Register

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State baru untuk toggle visibilitas password
  bool _isPasswordVisible = false;

  // --- DEFINISI WARNA BERDASARKAN HEX CODE ---
  final Color primaryBlue = const Color(0xFF005696); // Deep Blue
  final Color lightBackgroundColor = const Color(0xFFF0F2F5); // Very light grey for background
  final Color secondaryTextColor = Colors.grey.shade600;
  final Color pressedButtonColor = Colors.grey.shade700; // Warna abu-abu tua untuk efek tekan

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Fungsi Verifikasi Login (Logic Tidak Berubah) ---
  Future<void> _verifyLogin() async {
    final String identifier = _identifierController.text.trim();
    final String password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email atau Password wajib diisi!')));
      return;
    }

    try {
      String finalEmail;
      String uniqueDocId;

      // 1. Dapatkan Email dan ID Unik (NIM/Lecturer ID) dari Identifier
      DocumentSnapshot? userDoc;

      if (identifier.contains('@')) {
        // Kasus 1: Identifier adalah EMAIL
        finalEmail = identifier;

        QuerySnapshot emailSnapshot = await FirebaseFirestore.instance
            .collection('users').where('email', isEqualTo: finalEmail).limit(1).get();

        if (emailSnapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email tidak terdaftar.')));
          return;
        }

        userDoc = emailSnapshot.docs.first;
        uniqueDocId = userDoc.id;

      } else {
        // Kasus 2: Identifier adalah NIM atau LECTURER ID
        uniqueDocId = identifier;

        userDoc = await FirebaseFirestore.instance.collection('users').doc(uniqueDocId).get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID (NIM/Dosen) tidak terdaftar.')));
          return;
        }

        finalEmail = userDoc['email'];
      }

      if (userDoc == null || !userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mendapatkan data pengguna.')));
        return;
      }

      // 2. VERIFIKASI PASSWORD MENGGUNAKAN FIREBASE AUTH
      await _auth.signInWithEmailAndPassword(email: finalEmail, password: password);

      // 3. AMBIL DATA PROFIL LENGKAP
      final userData = userDoc.data() as Map<String, dynamic>;
      final userRole = userData['role'] ?? 'Student';

      // 4. Navigasi ke Dashboard (Meneruskan data lengkap)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeWrapper(
            userName: userData['full_name'] ?? 'Pengguna',
            userId: uniqueDocId,
            userRole: userRole,
          ),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil! Selamat datang, ${userData['full_name'] ?? 'Pengguna'} (${userRole}).'), backgroundColor: primaryBlue),
      );

    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        errorMessage = 'Email atau Password salah.';
      } else {
        errorMessage = 'Login gagal: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error Database: ${e.message}. Cek aturan Firestore.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan tak terduga.')));
    }
  }

  // --- Widget Input yang Disesuaikan dengan Desain ---
  Widget _buildInputField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    // Logika khusus untuk input password
    bool isObscured = isPassword ? !_isPasswordVisible : false;
    Widget? suffixIcon;

    if (isPassword) {
      suffixIcon = IconButton(
        icon: Icon(
          // Toggle ikon mata terbuka atau tertutup
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: secondaryTextColor,
        ),
        onPressed: () {
          // Mengubah state untuk menampilkan/menyembunyikan password
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label di atas Input Field
        Text(
          label,
          style: TextStyle(
            color: primaryBlue.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        // Input Field dengan border tipis dan latar belakang putih
        TextFormField(
          controller: controller,
          obscureText: isObscured, // Gunakan isObscured yang dipengaruhi state
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white, // Pastikan background input putih
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon, // Tambahkan ikon mata di sini
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primaryBlue, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // --- Header Logo dan Judul ---
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Icon (Graduation Cap)
        Icon(Icons.school, color: primaryBlue, size: 48),
        const SizedBox(height: 10),
        // President University
        Text('President University',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )
        ),
        // Student Portal
        Text('Student Portal',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: secondaryTextColor,
              fontWeight: FontWeight.w400,
            )
        ),
      ],
    );
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor, // Background sangat terang
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Batasi lebar card
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. HEADER
                _buildHeader(context),
                const SizedBox(height: 35),

                // 2. FORM CARD
                Container(
                  padding: const EdgeInsets.all(30.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Text
                      Text('Welcome Back',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 5),
                      Text('Sign in to access your academic dashboard',
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: secondaryTextColor)),
                      const SizedBox(height: 25),

                      // Input Email
                      _buildInputField(
                        label: 'Student Email',
                        hintText: 'student@president.ac.id',
                        controller: _identifierController,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      // Input Password
                      _buildInputField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                      ),

                      const SizedBox(height: 30),

                      // Tombol Sign In
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _verifyLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 5,
                            // FIX: Mengganti overlayColor dengan splashFactory atau menggunakan
                            // MaterialStateProperty.resolveWith yang diketik dengan benar di dalam styleFrom
                            // Jika error tetap muncul, berarti SDK yang digunakan terlalu lama.
                            // Kita ganti menjadi menggunakan style property eksplisit untuk compatibility.
                          ).copyWith(
                            overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return pressedButtonColor; // Abu-abu tua saat ditekan
                                }
                                return null; // Default value (biarkan theme yang menangani)
                              },
                            ),
                          ),
                          child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Forgot Password Link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Implementasi logika lupa password
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fungsi Lupa Password belum diimplementasi.')));
                          },
                          child: Text('Forgot your password?', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                        ),
                      ),

                      // Contact Admin (New student)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('New student? Contact admin@president.ac.id',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: secondaryTextColor.withOpacity(0.7))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // 3. FOOTER
                Text(
                  '© 2024 President University. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}