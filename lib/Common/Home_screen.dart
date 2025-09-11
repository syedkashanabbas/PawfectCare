import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String role; // 'Pet Owner', 'Veterinarian', 'Shelter Admin'

  const HomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Welcome to PawfectCare', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 100, color: Color(0xFF4CAF50)),
            const SizedBox(height: 20),
            Text(
              'You are logged in as',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 6),
            Text(
              role,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _navigateToDashboard(context, role);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Go to Dashboard", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, String role) {
    switch (role.toLowerCase()) {
      case 'pet owner':
        Navigator.pushNamed(context, '/petownerdashboard');
        break;
      case 'veterinarian':
        Navigator.pushNamed(context, '/vetdashboard');
        break;
      case 'shelter admin':
        Navigator.pushNamed(context, '/shelterdashboard');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unknown role — can't navigate.")),
        );
    }
  }
}
