import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VolunteerListScreen extends StatefulWidget {
  const VolunteerListScreen({super.key});

  @override
  State<VolunteerListScreen> createState() => _VolunteerListScreenState();
}

class _VolunteerListScreenState extends State<VolunteerListScreen> {
  final _volunteerRef = FirebaseDatabase.instance.ref('volunteers');
  List<Map<String, dynamic>> _volunteers = [];

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
  }

  void _fetchVolunteers() {
    _volunteerRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<Map<String, dynamic>> fetched = [];
        data.forEach((key, value) {
          if (value is Map) {
            value.forEach((childKey, childVal) {
              fetched.add(Map<String, dynamic>.from(childVal));
            });
          }
        });
        setState(() => _volunteers = fetched.reversed.toList());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Volunteer Submissions'),
      ),
      body: _volunteers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _volunteers.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final v = _volunteers[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.volunteer_activism, color: Colors.green),
              title: Text("${v['name']} (${v['availability']})"),
              subtitle: Text("${v['email']}\n${v['phone']}\n${v['reason']}"),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
