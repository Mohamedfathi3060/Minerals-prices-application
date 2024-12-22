import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications,
              size: 80,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome to Notification App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class SplashToHome extends StatefulWidget {
  const SplashToHome({super.key});

  @override
  State<SplashToHome> createState() => _SplashToHomeState();
}

class _SplashToHomeState extends State<SplashToHome> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
