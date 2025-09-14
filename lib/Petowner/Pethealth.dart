import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // To fetch doctor's name

class PetHealthScreen extends StatefulWidget {
  const PetHealthScreen({Key? key}) : super(key: key);

  @override
  _PetHealthScreenState createState() => _PetHealthScreenState();
}

class _PetHealthScreenState extends State<PetHealthScreen> {
  String? selectedPetId;
  List<String> petNames = [];
  Map<String, String> petIdMap = {}; // Map to store petId and pet names
  List<Map<String, dynamic>> healthRecords = [];
  bool isLoading = true;
  bool hasPets = false;

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  // Fetch pets belonging to the logged-in user
  void fetchPets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final dbRef = FirebaseDatabase.instance.ref("pets");

    dbRef.orderByChild("ownerId").equalTo(userId).onValue.listen((event) {
      final dataMap = event.snapshot.value;

      if (dataMap != null && dataMap is Map) {
        setState(() {
          petNames = [];
          petIdMap = {};
          dataMap.forEach((key, value) {
            if (value is Map) {
              petNames.add(value['name']);
              petIdMap[value['name']] = key;
            }
          });
          isLoading = false;
          hasPets = true; // Pets found for the user
        });
      } else {
        setState(() {
          isLoading = false;
          hasPets = false; // No pets found for the current user
        });
        print("No pets found for user.");
      }
    });
  }

  // Fetch health records based on selected petId
  void fetchHealthRecords(String petId) async {
    setState(() {
      isLoading = true; // Show loading state while fetching
    });

    final dbRef = FirebaseDatabase.instance.ref("healthRecords");

    dbRef.child(petId).onValue.listen((event) {
      final dataMap = event.snapshot.value;

      setState(() {
        if (dataMap != null && dataMap is Map) {
          healthRecords = dataMap.entries
              .map((e) => Map<String, dynamic>.from(e.value))
              .toList();
        } else {
          healthRecords = [];
        }
        isLoading = false; // Stop loading after data is fetched
      });
    });
  }

  // Fetch the doctor's name from Firestore using doctorId
  Future<String> fetchDoctorName(String doctorId) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(doctorId)
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data()?["name"] ?? "Unknown Doctor";
    }
    return "Unknown Doctor";
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text('Pet Health', style: TextStyle(color: Colors.white)),

        leading: const BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: greenColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Text(
                    "Wellness",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Medical Records",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select pet
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasPets
                ? _buildPetSelector()
                : const Center(child: Text("No pets available.")),

            const SizedBox(height: 20),

            // Show records only if a pet is selected
            if (selectedPetId != null && healthRecords.isNotEmpty) ...[
              // Vaccination Section
              _sectionCard(
                title: "Vaccinations",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record.containsKey("vaccination"))
                    .map(
                      (record) => _infoTile(
                        record["vaccination"] ?? "Untitled",
                        record["date"] ?? "Unknown",
                        fetchDoctorName(record["doctorId"] ?? ""),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              // Allergy Section
              _sectionCard(
                title: "Allergies",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record.containsKey("allergy"))
                    .map(
                      (record) => _infoTile(
                        record["allergy"] ?? "Untitled",
                        record["date"] ?? "Unknown",
                        fetchDoctorName(record["doctorId"] ?? ""),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              // Diagnosis Section
              _sectionCard(
                title: "Diagnosis",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record.containsKey("diagnosis"))
                    .map(
                      (record) => _infoTile(
                        record["diagnosis"] ?? "Untitled",
                        record["date"] ?? "Unknown",
                        fetchDoctorName(record["doctorId"] ?? ""),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              // Prescription Section
              _sectionCard(
                title: "Prescriptions",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record.containsKey("prescription"))
                    .map(
                      (record) => _infoTile(
                        record["prescription"] ?? "Untitled",
                        record["date"] ?? "Unknown",
                        fetchDoctorName(record["doctorId"] ?? ""),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              // Treatment Section
              _sectionCard(
                title: "Treatments",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record.containsKey("treatment"))
                    .map(
                      (record) => _infoTile(
                        record["treatment"] ?? "Untitled",
                        record["date"] ?? "Unknown",
                        fetchDoctorName(record["doctorId"] ?? ""),
                      ),
                    )
                    .toList(),
              ),
            ] else if (selectedPetId != null) ...[
              const Center(
                child: Text("No health records found for this pet."),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Custom Pet Selector (Dropdown)
  Widget _buildPetSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        hint: const Text("Select Pet", style: TextStyle(color: Colors.black)),
        value: selectedPetId,
        isExpanded: true,
        underline: const SizedBox(),
        onChanged: (String? newValue) {
          setState(() {
            selectedPetId = newValue;
            if (newValue != null) {
              fetchHealthRecords(
                petIdMap[newValue]!,
              ); // Fetch health records when a pet is selected
            }
          });
        },
        items: petNames.map((petName) {
          return DropdownMenuItem<String>(
            value: petName,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(petName, style: const TextStyle(fontSize: 16)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Health Records Section
  Widget _sectionCard({
    required String title,
    required VoidCallback onSeeAll,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    "See all",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  // Health Record Info Tile
  Widget _infoTile(
    String title,
    String subtitle,
    Future<String> doctorNameFuture,
  ) {
    return FutureBuilder<String>(
      future: doctorNameFuture,
      builder: (context, snapshot) {
        String doctorName = snapshot.data ?? "Unknown Doctor";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle),
            Text(doctorName, style: const TextStyle(color: Colors.grey)),
            const Divider(),
          ],
        );
      },
    );
  }
}
