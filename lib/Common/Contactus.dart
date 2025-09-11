import 'package:flutter/material.dart';

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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // No backend; show dummy confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message sent successfully!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Send Message", style: TextStyle(fontSize: 16)),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  String? _required(String? value) =>
      (value == null || value.isEmpty) ? "This field is required." : null;
}
