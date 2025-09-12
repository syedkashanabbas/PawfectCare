import 'package:flutter/material.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class DonationFormScreen extends StatefulWidget {
  const DonationFormScreen({super.key});

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  String? _paymentMethod;

  final List<String> _paymentOptions = ['Credit Card', 'Bank Transfer', 'Cash', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Make a Donation', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _label("Full Name"),
              TextFormField(
                controller: _nameController,
                decoration: _input("e.g., Hira Moin"),
                validator: _required,
              ),
              const SizedBox(height: 16),

              _label("Email"),
              TextFormField(
                controller: _emailController,
                decoration: _input("e.g., hira@example.com"),
                keyboardType: TextInputType.emailAddress,
                validator: _required,
              ),
              const SizedBox(height: 16),

              _label("Phone Number"),
              TextFormField(
                controller: _phoneController,
                decoration: _input("e.g., 0301-1234567"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _label("Donation Amount"),
              TextFormField(
                controller: _amountController,
                decoration: _input("Enter amount (e.g., 5000)"),
                keyboardType: TextInputType.number,
                validator: _required,
              ),
              const SizedBox(height: 16),

              _label("Payment Method"),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: _paymentOptions
                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (val) => setState(() => _paymentMethod = val),
                decoration: _input("Choose payment method"),
                validator: (val) => val == null ? "Please select one" : null,
              ),
              const SizedBox(height: 16),

              _label("Message (Optional)"),
              TextFormField(
                controller: _messageController,
                maxLines: 3,
                decoration: _input("Write a message or note..."),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Just UI response
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Donation form submitted (UI only)")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Donate Now", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  String? _required(String? val) => (val == null || val.isEmpty) ? "Required field" : null;
}
