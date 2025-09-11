import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  String? selectedRole;
  bool isLoading = false;

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a role")));
      return;
    }
    if (passCtrl.text != confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      setState(() => isLoading = true);

      // Create Firebase user
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passCtrl.text.trim(),
          );

      debugPrint(
        "✅ User created: ${userCred.user?.uid} ${userCred.user?.email}",
      );

      // Save extra info to Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
            "name": nameCtrl.text.trim(),
            "email": emailCtrl.text.trim(),
            "role": selectedRole,
            "createdAt": DateTime.now(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome ${nameCtrl.text}, role: $selectedRole"),
        ),
      );

      Navigator.pushReplacementNamed(context, "/login");
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ FirebaseAuth error: ${e.code} | ${e.message}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Auth error: ${e.code}")));
    } catch (e, stack) {
      debugPrint("❌ General error: $e\n$stack");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset("assets/images/coco.png", height: 120),
              const SizedBox(height: 20),

              CustomTextField(
                controller: nameCtrl,
                hintText: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: emailCtrl,
                hintText: 'Email Address',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: passCtrl,
                hintText: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: confirmCtrl,
                hintText: 'Confirm Password',
                icon: Icons.lock,
                obscure: true,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: "What best describes you?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pet Owner',
                    child: Text('Pet Owner'),
                  ),
                  DropdownMenuItem(
                    value: 'Veterinarian',
                    child: Text('Veterinarian'),
                  ),
                ],
                onChanged: (value) => setState(() => selectedRole = value),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isLoading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 40),

              const Text(
                '© All Rights Reserved to Pawfect Care - 2025',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscure;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
