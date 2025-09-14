import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AvailablePetsScreen extends StatefulWidget {
  const AvailablePetsScreen({super.key});

  @override
  State<AvailablePetsScreen> createState() => _AvailablePetsScreenState();
}

class _AvailablePetsScreenState extends State<AvailablePetsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  Set<String> requestedPetIds = {};
  String? selectedPetName;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserRequests();
  }

  Future<void> _loadUserRequests() async {
    if (currentUser == null) return;

    final snap = await FirebaseDatabase.instance
        .ref("adoptionRequests")
        .orderByChild("userId")
        .equalTo(currentUser!.uid)
        .get();

    if (snap.value == null) return;

    final data = Map<dynamic, dynamic>.from(snap.value as Map);
    final ids = data.values.map((e) => (e as Map)["petId"].toString()).toSet();

    setState(() => requestedPetIds = ids);
  }

  Future<void> _requestPet(Map<String, dynamic> pet) async {
    if (currentUser == null) return;

    if (requestedPetIds.contains(pet["id"])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You already requested this pet")),
      );
      return;
    }

    final reqRef = FirebaseDatabase.instance.ref("adoptionRequests").push();
    await reqRef.set({
      "userId": currentUser!.uid,
      "petId": pet["id"],
      "petName": pet["name"] ?? "",
      "status": "pending",
      "createdAt": DateTime.now().toIso8601String(),
    });

    setState(() => requestedPetIds.add(pet["id"]));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Request submitted!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Available Pets", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref("adminpets")
                  .orderByChild("status")
                  .equalTo("available")
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No available pets found"));
                }

                final raw = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                var pets = raw.entries.map((e) {
                  final data = Map<String, dynamic>.from(e.value);
                  data["id"] = e.key;
                  return data;
                }).toList();

                // apply filters
                if (selectedPetName != null && selectedPetName!.isNotEmpty) {
                  pets = pets.where((p) =>
                      (p["name"] ?? "").toString().toLowerCase().contains(selectedPetName!.toLowerCase())
                  ).toList();
                }
                if (selectedDate != null) {
                  pets = pets.where((p) {
                    final ts = p["timestamp"];
                    if (ts == null) return false;
                    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
                    return dt.year == selectedDate!.year &&
                        dt.month == selectedDate!.month &&
                        dt.day == selectedDate!.day;
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    final pet = pets[index];
                    final imageUrl = pet["imageUrl"] ?? "";

                    final alreadyRequested = requestedPetIds.contains(pet["id"]);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageUrl.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                                : Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Request image feature coming soon")),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text("Request Image"),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Name: ${pet["name"] ?? "Unknown"}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Species: ${pet["species"] ?? ""}"),
                            Text("Breed: ${pet["breed"] ?? ""}"),
                            Text("Age: ${pet["age"] ?? ""}"),
                            Text("Gender: ${pet["gender"] ?? ""}"),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: alreadyRequested ? null : () => _requestPet(pet),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: alreadyRequested ? Colors.grey : Colors.green,
                                ),
                                child: Text(alreadyRequested ? "Requested" : "Request"),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          _buildMyRequests()
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Filter by name",
                filled: true,
              ),
              onChanged: (val) => setState(() => selectedPetName = val),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
            child: const Text("Filter by Date"),
          )
        ],
      ),
    );
  }

  Widget _buildMyRequests() {
    return SizedBox(
      height: 200,
      child: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref("adoptionRequests")
            .orderByChild("userId")
            .equalTo(currentUser?.uid)
            .onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No requests yet"));
          }
          final raw = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final requests = raw.values.map((e) => Map<String, dynamic>.from(e)).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final r = requests[index];
              final status = r["status"] ?? "pending";

              return Container(
                width: 200,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r["petName"] ?? "Pet", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Status: $status", style: TextStyle(
                      color: status == "approved" ? Colors.green : (status == "rejected" ? Colors.red : Colors.orange),
                    )),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
