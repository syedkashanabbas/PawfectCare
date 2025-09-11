import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerFormScreen extends StatefulWidget {
  const VolunteerFormScreen({super.key});

  @override
  State<VolunteerFormScreen> createState() => _VolunteerFormScreenState();
}

class _VolunteerFormScreenState extends State<VolunteerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _availability;

  bool _isLoading = false;

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("volunteers"); // node volunteers

  final List<String> _availabilityOptions = [
    'Weekdays',
    'Weekends',
    'Evenings',
    'Flexible',
  ];

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final volunteerData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "availability": _availability ?? "",
      "reason": _reasonController.text.trim(),
      "createdAt": DateTime.now().toIso8601String(),
    };

    await dbRef.push().set(volunteerData);

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Volunteer form submitted successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                _formKey.currentState!.reset();
                _nameController.clear();
                _emailController.clear();
                _phoneController.clear();
                _reasonController.clear();
                setState(() {
                  _availability = null;
                });
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Volunteer Signup',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionLabel("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("e.g., Ayesha Khan"),
                validator: _required,
              ),
              const SizedBox(height: 16),

              _sectionLabel("Email"),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("e.g., ayesha@example.com"),
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              const SizedBox(height: 16),

              _sectionLabel("Phone Number"),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration("e.g., 0300-1234567"),
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 16),

              _sectionLabel("Availability"),
              DropdownButtonFormField<String>(
                value: _availability,
                items: _availabilityOptions
                    .map((opt) =>
                        DropdownMenuItem(value: opt, child: Text(opt)))
                    .toList(),
                onChanged: (value) => setState(() => _availability = value),
                decoration: _inputDecoration("Select availability"),
                validator: (val) => val == null ? "Please select one" : null,
              ),
              const SizedBox(height: 16),

              _sectionLabel("Why do you want to volunteer?"),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: _inputDecoration("Tell us a bit..."),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Submit",
                          style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
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
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  String? _required(String? value) {
    return (value == null || value.isEmpty) ? 'Required field' : null;
  }
}
