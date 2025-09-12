import 'package:flutter/material.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';
import 'package:firebase_database/firebase_database.dart';

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

  bool _isLoading = false;

  final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref("donations"); 

  final List<String> _paymentOptions = [
    'Credit Card',
    'Bank Transfer',
    'Cash',
    'Other'
  ];

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final donationData = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "amount": _amountController.text.trim(),
      "paymentMethod": _paymentMethod ?? "",
      "message": _messageController.text.trim(),
      "createdAt": DateTime.now().toIso8601String(),
    };

    await dbRef.push().set(donationData);

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Thank You"),
          content: const Text("Your donation has been recorded successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                _formKey.currentState!.reset();
                _nameController.clear();
                _emailController.clear();
                _phoneController.clear();
                _amountController.clear();
                _messageController.clear();
                setState(() {
                  _paymentMethod = null;
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
        title: const Text('Make a Donation',
            style: TextStyle(color: Colors.white)),
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
                    .map((method) =>
                        DropdownMenuItem(value: method, child: Text(method)))
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

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Donate Now",
                          style: TextStyle(fontSize: 16)),
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
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
    );
  }

  String? _required(String? val) =>
      (val == null || val.isEmpty) ? "Required field" : null;
}
