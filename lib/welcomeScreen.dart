import 'package:flutter/material.dart';
import 'package:pawfectcare/login.dart';
import 'package:pawfectcare/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA7DADC),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/coco.png",
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "COCO",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B2333), // dark maroon shade
              ),
            ),
            const SizedBox(height: 32),

            // --- Welcome Text ---
            const Text(
              "Hey! Welcome",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            const Text(
              "While You Sit And Stay - We'll\nGo Out And Play",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),

            // --- Get Started Button ---
            ElevatedButton(
              onPressed: () {
                // navigation ya action yaha add karo
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF90), // green button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Signup(),
                  ));
                },
                child: const Text(
                  "GET STARTED",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- Already have account? ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Login action
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const login()),
                      );
                    },
                    child: const Text(
                      "login",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF90), // green color for login
                      ),
                    ),
                  ),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
