import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
    final dbRef = FirebaseDatabase.instance.ref("healthRecords");

    dbRef.orderByChild("petId").equalTo(petId).onValue.listen((event) {
      final dataMap = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      setState(() {
        healthRecords = dataMap.entries
            .map((e) => Map<String, dynamic>.from(e.value))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text('Pet Health'),
        leading: const BackButton(color: Colors.white),
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
              _sectionCard(
                title: "Vaccinations",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record["recordType"] == "vaccination")
                    .map((record) => _infoTile(
                  record["title"] ?? "Untitled",
                  record["date"] ?? "Unknown",
                  record["doctor"] ?? "Unknown",
                ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _sectionCard(
                title: "Allergies",
                onSeeAll: () {},
                children: healthRecords
                    .where((record) => record["recordType"] == "allergy")
                    .map((record) => _infoTile(
                  record["title"] ?? "Untitled",
                  record["date"] ?? "Unknown",
                  record["doctor"] ?? "Unknown",
                ))
                    .toList(),
              ),
            ] else if (selectedPetId != null) ...[
              const Center(child: Text("No health records found for this pet."))
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
              fetchHealthRecords(petIdMap[newValue]!); // Fetch health records when a pet is selected
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
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text("See all", style: TextStyle(color: Colors.blue)),
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
  Widget _infoTile(String title, String subtitle, String doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle),
        Text(doctor, style: const TextStyle(color: Colors.grey)),
        const Divider(),
      ],
    );
  }
}
