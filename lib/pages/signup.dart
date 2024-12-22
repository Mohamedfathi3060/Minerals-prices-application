import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(context),
                SizedBox(height: 40),
                _headerText(),
                SizedBox(height: 40),
                _usernameField(),
                SizedBox(height: 20),
                _emailField(),
                SizedBox(height: 20),
                _passwordField(),
                SizedBox(height: 40),
                _signUpButton(context),
                SizedBox(height: 40),
                _signInText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _headerText() {
    return Text(
      'Create Account',
      style: GoogleFonts.poppins(
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  Widget _usernameField() {
    return _inputField(
      controller: _usernameController,
      hintText: 'Username',
      icon: Icons.person_outline,
    );
  }

  Widget _emailField() {
    return _inputField(
      controller: _emailController,
      hintText: 'Email Address',
      icon: Icons.email_outlined,
    );
  }

  Widget _passwordField() {
    return _inputField(
      controller: _passwordController,
      hintText: 'Password',
      icon: Icons.lock_outline,
      isPassword: true,
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _signUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () async {
          await AuthService().signup(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
            context: context,
          );
        },
        child: Text(
          "Sign Up",
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Color(0xFF1A237E),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _signInText(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "Already Have Account? ",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            TextSpan(
              text: "Log In",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}

class UserModel {
  final String? username;
  final String? email;
  final String? password;

  const UserModel({this.username, this.email, this.password});

  Map<String, dynamic> toJson() {
    return {"username": username, "email": email, "password": password};
  }

  factory UserModel.fromJson(Map<String, dynamic> user) {
    return UserModel(
      username: user['username'] ?? '',
      email: user['email'] ?? '',
      password: user['password'] ?? '',
    );
  }
}
