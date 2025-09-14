import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class VetAssignmentScreen extends StatefulWidget {
  const VetAssignmentScreen({super.key});

  @override
  _VetAssignmentScreenState createState() => _VetAssignmentScreenState();
}

class _VetAssignmentScreenState extends State<VetAssignmentScreen> {
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  // Fetch pending assignments for the vet
  Future<void> _loadAssignments() async {
    final vetId = FirebaseAuth.instance.currentUser?.uid;
    if (vetId == null) return;

    final snapshot = await FirebaseDatabase.instance
        .ref('petAssignments')
        .orderByChild('vetId')
        .equalTo(vetId)
        .get();

    if (snapshot.value != null) {
      final assignmentsMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
      setState(() {
        _assignments = assignmentsMap.entries.map((entry) {
          return {
            'id': entry.key,
            'vetId': entry.value['vetId'],
            'petId': entry.value['petId'],
            'petName': entry.value['petName'],
            'ownerId': entry.value['ownerId'],
            'status': entry.value['status'],
            'createdAt': entry.value['createdAt'],
          };
        }).toList();
      });
    }
  }

  // Update the assignment status to 'Accepted' or 'Rejected'
  Future<void> _updateAssignmentStatus(String assignmentId, String status) async {
    final ref = FirebaseDatabase.instance.ref('petAssignments/$assignmentId');
    await ref.update({'status': status});

    // Reload assignments after the update
    _loadAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Vet Assignments"),
      ),
      body: _assignments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final assignment = _assignments[index];
          final petName = assignment['petName'];
          final status = assignment['status'];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(petName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Status: $status'),
              trailing: status == 'Pending'
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateAssignmentStatus(assignment['id'], 'Accepted'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red),
                    onPressed: () => _updateAssignmentStatus(assignment['id'], 'Rejected'),
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
