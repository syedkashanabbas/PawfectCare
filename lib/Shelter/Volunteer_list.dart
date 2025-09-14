import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  final _volunteerRef = FirebaseDatabase.instance.ref('volunteers');
  Map<String, Map<String, dynamic>> _volunteers = {};

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
  }

  void _fetchVolunteers() {
    _volunteerRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final Map<String, Map<String, dynamic>> fetched = {};
        data.forEach((key, value) {
          if (value is Map) {
            fetched[key] = Map<String, dynamic>.from(value);
          }
        });
        setState(() => _volunteers = Map.fromEntries(fetched.entries.toList().reversed));
      }
    });
  }

  void _showEditPopup(String key, Map<String, dynamic> volunteer) {
    final nameController = TextEditingController(text: volunteer['name']);
    final emailController = TextEditingController(text: volunteer['email']);
    final phoneController = TextEditingController(text: volunteer['phone']);
    final reasonController = TextEditingController(text: volunteer['reason']);
    final availabilityController = TextEditingController(text: volunteer['availability']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Volunteer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason')),
              TextField(controller: availabilityController, decoration: const InputDecoration(labelText: 'Availability')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              _volunteerRef.child(key).update({
                'name': nameController.text,
                'email': emailController.text,
                'phone': phoneController.text,
                'reason': reasonController.text,
                'availability': availabilityController.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keys = _volunteers.keys.toList();
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Volunteer', style: TextStyle(color: Colors.white),),
      ),
      drawer: const ShelterDrawer(),
      body: _volunteers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _volunteers.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final key = keys[index];
          final v = _volunteers[key]!;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism, color: Colors.green),
              title: Text("${v['name']} (${v['availability']})"),
              subtitle: Text("${v['email']}\n${v['phone']}\n${v['reason']}"),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showEditPopup(key, v),
              ),
            ),
          );
        },
      ),
    );
  }
}
