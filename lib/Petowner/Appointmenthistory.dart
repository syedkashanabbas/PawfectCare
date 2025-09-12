import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  final Color greenColor = const Color(0xFF4CAF50);
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final dbRef = FirebaseDatabase.instance.ref("appointments");

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text(
          "My Appointments",
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      drawer: const PetOwnerDrawer(),
      body: StreamBuilder(
        stream: dbRef.orderByChild("ownerId").equalTo(userId).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No appointments found"));
          }

          final data =
          Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final appointments = data.entries.map((e) {
            final appt = Map<String, dynamic>.from(e.value);
            appt["id"] = e.key;
            return appt;
          }).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(appointments, "Pending"),
              _buildList(appointments, "Upcoming"),
              _buildList(appointments, "Completed"),
              _buildList(appointments, "Cancelled"),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> appointments, String filter) {
    final filtered = appointments
        .where((a) =>
    (a["status"] ?? "Pending").toString().toLowerCase() ==
        filter.toLowerCase())
        .toList();

    if (filtered.isEmpty) {
      return Center(child: Text("No $filter appointments"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final appt = filtered[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(appt["vetId"])
              .get(),
          builder: (context, vetSnap) {
            String vetName = appt["vetName"] ?? "Unknown Vet";
            String vetEmail = "";
            String vetImage = "";

            if (vetSnap.hasData && vetSnap.data!.exists) {
              final vetData = vetSnap.data!.data() as Map<String, dynamic>;
              vetName = vetData["name"] ?? vetName;
              vetEmail = vetData["email"] ?? "";
              vetImage = vetData["profileImage"] ?? "";
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage:
                      vetImage.isNotEmpty ? NetworkImage(vetImage) : null,
                      child: vetImage.isEmpty
                          ? const Icon(Icons.person, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vetName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          if (vetEmail.isNotEmpty)
                            Text(vetEmail,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text("Date: ${appt["date"] ?? ""}",
                              style: const TextStyle(fontSize: 14)),
                          Text("Time: ${appt["time"] ?? ""}",
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          _buildStatusChip(appt["status"] ?? "Pending"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    final isCompleted = status.toLowerCase() == 'completed';
    final isCancelled = status.toLowerCase() == 'cancelled';
    final isUpcoming = status.toLowerCase() == 'upcoming';
    final isPending = status.toLowerCase() == 'pending';

    return Chip(
      label: Text(status),
      backgroundColor: isCompleted
          ? Colors.green.shade100
          : isCancelled
          ? Colors.red.shade100
          : isUpcoming
          ? Colors.blue.shade100
          : Colors.orange.shade100,
      labelStyle: TextStyle(
        color: isCompleted
            ? Colors.green.shade800
            : isCancelled
            ? Colors.red.shade800
            : isUpcoming
            ? Colors.blue.shade800
            : Colors.orange.shade800,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
