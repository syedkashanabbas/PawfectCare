import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } else {
      try {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          Navigator.pushReplacementNamed(context, "/login");
          return;
        }

        final data = doc.data() as Map<String, dynamic>;
        final role = (data["role"] ?? "").toString();

        if (mounted) {
          if (role == "Super Admin") {
            Navigator.pushReplacementNamed(context, "/contactus");
          } else if (role == "Veterinarian") {
            Navigator.pushReplacementNamed(context, "/vetdashboard");
          } else if (role == "Pet Owner") {
            Navigator.pushReplacementNamed(context, "/petownerdashboard");
          } else {
            // fallback if role not set
            Navigator.pushReplacementNamed(context, "/login");
          }
        }
      } catch (e) {
        debugPrint("Error checking role: $e");
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/login");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF65C057),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/splash.png", height: 200),
            const SizedBox(height: 30),
            const Text(
              'LOADING',
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
