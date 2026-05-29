import 'package:flutter/material.dart';
import 'package:voca_assist/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 1. Save to Global (for immediate use)
      globals.loggedInUsername = _userController.text;

      // 2. Save to Firestore Database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userController.text)
          .set({
            'name': _userController.text,
            'email': _emailController.text,
            'role': 'New Analyst',
            'total_chats': 0,
            'words_count': 0,
            'profile_image': 'https://via.placeholder.com/150',
            'created_at': FieldValue.serverTimestamp(), //
          });

      if (mounted) Navigator.pushReplacementNamed(context, '/chat');
    } else {
      // NOTIFICATION: Floating error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? "Missing login details!"
                : "Please fill all fields and follow criteria",
          ),
          backgroundColor: Colors.orange[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3DA4FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _isLogin ? "Welcome Back!" : "Create Account",
                key: ValueKey<bool>(_isLogin),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(30),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _toggleButton("Login", _isLogin),
                          const SizedBox(width: 20),
                          _toggleButton("Register", !_isLogin),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _inputField(
                        "Username",
                        "Enter your username",
                        _userController,
                        false,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _isLogin ? 0 : 90,
                        child: SingleChildScrollView(
                          child: _inputField(
                            "Email",
                            "Enter your email",
                            _emailController,
                            false,
                          ),
                        ),
                      ),
                      _inputField(
                        "Password",
                        "Enter your password",
                        _passwordController,
                        true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3DA4FF),
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          _isLogin ? "LOGIN" : "REGISTER",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isLogin = (text == "Login")),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? const Color(0xFF3DA4FF) : Colors.grey,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 60 : 0,
            color: const Color(0xFF3DA4FF),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    String hint,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Cannot be empty';
              }
              if (label == "Email" && !value.contains('@')) {
                return 'Enter a valid email';
              }
              if (isPassword && value.length < 6) {
                return 'Min 6 characters';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFE3F2FD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
