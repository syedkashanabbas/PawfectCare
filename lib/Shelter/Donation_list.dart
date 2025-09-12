import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DonationListScreen extends StatefulWidget {
  const DonationListScreen({super.key});

  @override
  State<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends State<DonationListScreen> {
  final _donationRef = FirebaseDatabase.instance.ref('donations');
  List<Map<String, dynamic>> _donations = [];

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  void _fetchDonations() {
    _donationRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> fetched = [];

        data.forEach((key, value) {
          if (value is Map) {
            fetched.add(Map<String, dynamic>.from(value));
          }
        });

        setState(() => _donations = fetched.reversed.toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Donations'),
      ),
      body: _donations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _donations.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final d = _donations[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism,
                  color: Colors.green),
              title: Text("${d['name']} (${d['paymentMethod']})"),
              subtitle: Text(
                  "${d['email']}\n${d['phone']}\n${d['message']}"),
              trailing: Text("Rs. ${d['amount']}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
