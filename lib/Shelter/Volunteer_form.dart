import 'package:flutter/material.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

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

  final List<String> _availabilityOptions = [
    'Weekdays',
    'Weekends',
    'Evenings',
    'Flexible',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Volunteer Signup', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
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
                    .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
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

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Form submitted (dummy logic).")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit", style: TextStyle(fontSize: 16)),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
