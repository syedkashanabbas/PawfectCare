import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

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
            final map = Map<String, dynamic>.from(value);
            map['id'] = key;
            fetched.add(map);
          }
        });

        setState(() => _donations = fetched.reversed.toList());
      }
    });
  }

  void _showDonationForm({Map<String, dynamic>? donation}) {
    final nameCtrl = TextEditingController(text: donation?['name'] ?? "");
    final emailCtrl = TextEditingController(text: donation?['email'] ?? "");
    final phoneCtrl = TextEditingController(text: donation?['phone'] ?? "");
    final methodCtrl = TextEditingController(text: donation?['paymentMethod'] ?? "");
    final messageCtrl = TextEditingController(text: donation?['message'] ?? "");
    final amountCtrl = TextEditingController(text: donation?['amount'] ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(donation == null ? "Add Donation" : "Edit Donation"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
                TextField(controller: methodCtrl, decoration: const InputDecoration(labelText: "Payment Method")),
                TextField(controller: messageCtrl, decoration: const InputDecoration(labelText: "Message")),
                TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Amount")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  "name": nameCtrl.text,
                  "email": emailCtrl.text,
                  "phone": phoneCtrl.text,
                  "paymentMethod": methodCtrl.text,
                  "message": messageCtrl.text,
                  "amount": amountCtrl.text,
                  "createdAt": DateTime.now().toIso8601String(),
                };

                if (donation == null) {
                  await _donationRef.push().set(payload);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Donation added")),
                  );
                } else {
                  await _donationRef.child(donation['id']).update(payload);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Donation updated")),
                  );
                }

                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteDonation(Map<String, dynamic> donation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Donation"),
        content: const Text("Are you sure you want to delete this donation?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _donationRef.child(donation['id']).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Donation deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Donations'),
      ),
      drawer: const ShelterDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () => _showDonationForm(),
        child: const Icon(Icons.add),
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
                    leading: const Icon(Icons.volunteer_activism, color: Colors.green),
                    title: Text("${d['name']} (${d['paymentMethod']})"),
                    subtitle: Text("${d['email']}\n${d['phone']}\n${d['message']}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "edit") {
                          _showDonationForm(donation: d);
                        } else if (value == "delete") {
                          _deleteDonation(d);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
