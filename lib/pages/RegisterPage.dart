import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  // Controller yang ada
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _lecturerIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State
  String? _selectedRole;
  String? _selectedGender;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // Tambahkan Instance Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- DEFINISI WARNA BERDASARKAN HEX CODE ---
  final Color primaryBlue = const Color(0xFF005696); // Deep Blue
  final Color accentBlack = Colors.black; // Hitam sebagai aksen
  final Color backgroundColor = const Color(0xFFF5F5F5); // Light Grey
  // ---------------------------

  @override
  void dispose() {
    _nimController.dispose();
    _lecturerIdController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- Fungsi Penyimpanan Data ke Firestore ---
  Future<void> _registerUser() async {
    setState(() => _isLoading = true);
    final String email = _emailController.text.trim();
    final String fullName = _fullNameController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String uniqueId = _selectedRole == 'Student'
        ? _nimController.text.trim()
        : _lecturerIdController.text.trim();
    final String idFieldName = _selectedRole == 'Student' ? 'nim' : 'lecturer_id';

    // --- VALIDASI PERAN ---
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Must choose (Student/Lecturer) role.', style: TextStyle(color: Colors.white)),
          backgroundColor: accentBlack,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    // --- [MODIFIKASI] VALIDASI DOMAIN DINAMIS ---
    String requiredDomain;
    if (_selectedRole == 'Student') {
      requiredDomain = '@student.president.ac.id';
    } else {
      requiredDomain = '@president.ac.id';
    }

    if (!email.endsWith(requiredDomain)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email for $_selectedRole must use domain $requiredDomain', style: const TextStyle(color: Colors.white)),
          backgroundColor: accentBlack,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }
    // ---------------------------------------------

    // Validasi Field Wajib Umum
    if (uniqueId.isEmpty || email.isEmpty || fullName.isEmpty || password.isEmpty || confirmPassword.isEmpty || _selectedGender == null || !_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields and agreement must be filled!'), backgroundColor: Colors.red));
      setState(() => _isLoading = false); // Jangan lupa matikan loading
      return;
    }

    // Validasi Password
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password and Confirm Password is not match!'), backgroundColor: Colors.red));
      setState(() => _isLoading = false);
      return;
    }
    // --- END VALIDASI ---

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uniqueId).set({
        'user_id': userId,
        idFieldName: uniqueId, // nim atau lecturer_id
        'email': email,
        'full_name': fullName,
        'gender': _selectedGender,
        'role': _selectedRole,
        'registration_date': FieldValue.serverTimestamp(),
        'status': 'active',
        'profile_image_url': 'https://picsum.photos/seed/default/200/200',
        // Default stats bisa disesuaikan kalau Lecturer tidak butuh GPA/Credits
        'gpa': _selectedRole == 'Student' ? 3.6 : 0.0,
        'courses': 0,
        'credits': 0,
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ID $uniqueId registered successfully! Please Login.'),
          backgroundColor: primaryBlue,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already registered. Please login.';
      } else {
        errorMessage = 'Failed to register: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Database: ${e.message}'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected Error.'), backgroundColor: Colors.red),
      );
    }
  }

  // --- WIDGET BARU: Pemilihan Peran ---
  Widget _buildRoleSelection(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: _buildRoleRadioTile('Student', color)),
                Expanded(child: _buildRoleRadioTile('Lecturer', color)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleRadioTile(String title, Color color) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.grey.shade800)),
      leading: Radio<String>(
        value: title,
        groupValue: _selectedRole,
        onChanged: (String? value) {
          setState(() {
            _selectedRole = value;
            _nimController.clear();
            _lecturerIdController.clear();
            _emailController.clear(); // Bersihkan email saat ganti role agar hint terlihat
          });
        },
        activeColor: color,
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // --- WIDGET DINAMIS: Input ID/NIM/Email ---
  Widget _buildDynamicInputFields(Color primaryColor, Color accentColor) {
    if (_selectedRole == null) {
      return const SizedBox.shrink();
    }

    String idLabel = _selectedRole == 'Student' ? 'Student ID' : 'Lecturer ID';
    TextEditingController idController = _selectedRole == 'Student' ? _nimController : _lecturerIdController;
    TextInputType idType = _selectedRole == 'Student' ? TextInputType.number : TextInputType.text;
    IconData idIcon = _selectedRole == 'Student' ? Icons.badge : Icons.school;

    // [MODIFIKASI] Hint Dinamis
    String hintDomain = _selectedRole == 'Student'
        ? '@student.president.ac.id'
        : '@president.ac.id';

    return Column(
      children: [
        // Input ID Dosen / NIM Mahasiswa
        _buildInputField(idLabel, idIcon, idType, primaryColor, accentColor, controller: idController),
        const SizedBox(height: 15),

        // Input Email Kampus
        _buildInputField(
          'University Email',
          Icons.email,
          TextInputType.emailAddress,
          primaryColor,
          accentColor,
          controller: _emailController,
          hintText: 'ex: name$hintDomain', // Menampilkan contoh format
          hintColor: Colors.grey,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    final primaryColor = primaryBlue;
    final accentColor = accentBlack;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text('Register New Account'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Area Kosong/Padding di Atas
            Container(
              height: screenHeight * 0.05,
              color: primaryColor,
            ),

            // FORM CARD CONTAINER
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight * 0.95),
              padding: const EdgeInsets.only(top: 30, left: 25.0, right: 25.0, bottom: 40),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // SELECTION: Role
                  _buildRoleSelection(primaryColor),
                  const SizedBox(height: 25),

                  // Input Nama Lengkap
                  _buildInputField('Full Name', Icons.person, TextInputType.text, primaryColor, accentColor, controller: _fullNameController),
                  const SizedBox(height: 15),

                  // Input Dinamis (NIM/ID Dosen & Email)
                  _buildDynamicInputFields(primaryColor, accentColor),

                  // Input Password
                  _buildPasswordField('Password', primaryColor, accentColor, controller: _passwordController),
                  const SizedBox(height: 15),

                  // Input Konfirmasi Password
                  _buildPasswordField('Confirm Password', primaryColor, accentColor, controller: _confirmPasswordController),
                  const SizedBox(height: 30),

                  // SELECTION: Gender
                  _buildGenderSelection(primaryColor),
                  const SizedBox(height: 20),

                  // CHECKBOX: Syarat & Ketentuan
                  _buildTermsCheckbox(primaryColor),
                  const SizedBox(height: 30),

                  // Tombol Daftar (Button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('REGISTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),),
                  ),
                  const SizedBox(height: 20),

                  // Link ke Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          'Login here',
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS PENDUKUNG ---

  Widget _buildGenderSelection(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              Expanded(child: _buildRadioTile('Male', color)),
              Expanded(child: _buildRadioTile('Female', color)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile(String title, Color color) {
    return ListTile(
      title: Text(title, style: TextStyle(color: Colors.grey.shade800)),
      leading: Radio<String>(
        value: title,
        groupValue: _selectedGender,
        onChanged: (String? value) { setState(() { _selectedGender = value; }); },
        activeColor: color,
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildTermsCheckbox(Color color) {
    return Row(
      children: [
        Checkbox(value: _agreedToTerms, onChanged: (bool? value) { setState(() { _agreedToTerms = value!; }); }, activeColor: color),
        Expanded(child: Text('I agree to the Terms & Conditions.', style: TextStyle(fontSize: 14, color: Colors.grey.shade700))),
      ],
    );
  }

  Widget _buildInputField(String label, IconData icon, TextInputType type, Color color, Color accentColor, {required TextEditingController controller, String? hintText, Color? hintColor}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color),
          hintText: hintText,
          hintStyle: TextStyle(color: hintColor ?? Colors.grey),
          prefixIcon: Icon(icon, color: accentColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, Color color, Color accentColor, {required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: color),
          prefixIcon: Icon(Icons.lock, color: accentColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: color, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
      ),
    );
  }
}