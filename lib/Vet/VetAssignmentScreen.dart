import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Fetch assignments for the logged-in vet
  Future<void> _loadAssignments() async {
    final vetId = FirebaseAuth.instance.currentUser?.uid;

    if (vetId == null) {
      print("Error: No vet is logged in");
      return;
    }

    print("Fetching assignments for vetId: $vetId");

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('petAssignments')
          .orderByChild('vetId')
          .equalTo(vetId)
          .get();

      if (snapshot.exists) {
        final assignmentsMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
        print("Assignments found: ${assignmentsMap.length}");  // Debug print

        for (var entry in assignmentsMap.entries) {
          final assignment = entry.value;

          // Only proceed if the assignment's status is 'Pending'
          if (assignment['status'] == 'Pending') {
            final petId = assignment['petId'];

            // Fetch the ownerId from the 'pets' table using the petId
            final petSnapshot = await FirebaseDatabase.instance
                .ref('pets')
                .child(petId)
                .get();

            if (petSnapshot.exists) {
              final petData = Map<String, dynamic>.from(petSnapshot.value as Map);
              final ownerId = petData['ownerId'];

              // Fetch the owner's name from the 'users' table
              final ownerSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(ownerId)
                  .get();

              if (ownerSnapshot.exists) {
                final ownerData = ownerSnapshot.data() as Map<String, dynamic>;
                final ownerName = ownerData['name'];

                setState(() {
                  _assignments.add({
                    'id': entry.key,
                    'vetId': assignment['vetId'],
                    'vetName': assignment['vetName'],
                    'petId': assignment['petId'],
                    'petName': assignment['petName'],
                    'ownerId': ownerId,
                    'ownerName': ownerName, // Add the owner's name here
                    'status': assignment['status'],
                  });
                });
              }
            }
          }
        }
      } else {
        print("No assignments found for this vet");
      }
    } catch (e) {
      print("Error fetching assignments: $e");
    }
  }

  // Accept or reject the assignment
  Future<void> _updateAssignmentStatus(String assignmentId, String status) async {
    final assignmentRef = FirebaseDatabase.instance.ref('petAssignments/$assignmentId');
    await assignmentRef.update({'status': status});

    // Remove the assignment from the list if the status is changed
    setState(() {
      _assignments.removeWhere((assignment) => assignment['id'] == assignmentId);
    });

    print("Assignment status updated: $status");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Pets"),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: _assignments.isEmpty
          ? const Center(child: Text("No pending assignments"))
          : ListView.builder(
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final assignment = _assignments[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(assignment['petName'] ?? "Unknown Pet"),
              subtitle: Text('Owner: ${assignment['ownerName']}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      _updateAssignmentStatus(assignment['id'], 'Accepted');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {
                      _updateAssignmentStatus(assignment['id'], 'Rejected');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
