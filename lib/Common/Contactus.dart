import 'dart:ui_web' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child("contact_messages");

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'google-maps-iframe',
        (int viewId) => html.IFrameElement()
          ..src =
              'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3619.902488409029!2d67.01937544321065!3d24.867179788265563!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3eb33e6b1566c46f%3A0x65318f4eb62c7aa8!2sAptech%20Computer%20Education%20Garden%20Center!5e0!3m2!1sen!2s!4v1757681807100!5m2!1sen!2s'
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("e.g., Saifullah Mirza"),
                validator: _required,
              ),
              const SizedBox(height: 16),

              _label("Email"),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("e.g., saif@example.com"),
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              const SizedBox(height: 16),

              _label("Message"),
              TextFormField(
                controller: _messageController,
                decoration: _inputDecoration("Write your message here..."),
                maxLines: 5,
                validator: _required,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _dbRef.push().set({
                      "name": _nameController.text,
                      "email": _emailController.text,
                      "message": _messageController.text,
                      "timestamp": DateTime.now().toIso8601String(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message sent successfully!")),
                    );

                    _nameController.clear();
                    _emailController.clear();
                    _messageController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Send Message", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 30),

              _label("Our Location"),
              const SizedBox(height: 10),

              SizedBox(
                height: 300,
                child: kIsWeb
                    ? const HtmlElementView(viewType: 'google-maps-iframe')
                    : const Center(child: Text("Map only available on Web")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  String? _required(String? value) =>
      (value == null || value.isEmpty) ? "This field is required." : null;
}
