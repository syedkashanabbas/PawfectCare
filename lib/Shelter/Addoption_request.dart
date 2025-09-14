import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class AdoptionRequestsScreen extends StatelessWidget {
  const AdoptionRequestsScreen({super.key});

  Future<void> _updateStatus(String reqId, String status) async {
    await FirebaseDatabase.instance
        .ref("adoptionRequests")
        .child(reqId)
        .update({"status": status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Adoption Requests', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref("adoptionRequests").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No adoption requests found"));
          }

          final raw = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final requests = raw.entries.map((e) {
            final data = Map<String, dynamic>.from(e.value);
            data["id"] = e.key;
            return data;
          }).toList();

          // sort latest first
          requests.sort((a, b) => (b["createdAt"] ?? "").compareTo(a["createdAt"] ?? ""));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final status = req["status"] ?? "pending";
              final userId = req["userId"];

              String formattedDate = "";
              if (req["createdAt"] != null) {
                try {
                  final dt = DateTime.tryParse(req["createdAt"]);
                  if (dt != null) {
                    formattedDate = DateFormat("yyyy-MM-dd").format(dt);
                  }
                } catch (_) {}
              }

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pet: ${req['petName'] ?? 'Unknown'}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                      // ✅ Fetch adopter name from Firestore users collection
                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Adopter: ...");
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text("Adopter: Unknown");
                          }
                          final data = snapshot.data!.data() as Map<String, dynamic>;
                          return Text("Adopter: ${data["name"] ?? "Unknown"}");
                        },
                      ),

                      Text("Requested On: $formattedDate"),
                      Text("Status: $status", style: TextStyle(
                        color: status == 'approved'
                            ? Colors.green
                            : status == 'rejected'
                            ? Colors.red
                            : Colors.orange,
                      )),
                      const SizedBox(height: 10),

                      if (status == 'pending')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _updateStatus(req["id"], "rejected"),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text("Reject", style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _updateStatus(req["id"], "approved"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                              child: const Text("Approve", style: TextStyle(color: Colors.white),),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
