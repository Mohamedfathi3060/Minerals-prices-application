import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth.dart';
import 'channels.dart';
import 'users.dart';
import 'splash.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color(0xFFF5F5F5),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildActionCards(context),
                  const Spacer(),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user != null ? user.email! : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: GoogleFonts.raleway(
            textStyle: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _buildCard(
          context,
          "Show Users",
          Icons.people_outline,
              () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsersPage()),
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          context,
          "View Channels",
          Icons.chat_bubble_outline,
              () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChannelsPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Colors.black),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await AuthService().signout(context: context);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SplashScreen()),
          );
        },
        child: Text(
          "Sign Out",
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
