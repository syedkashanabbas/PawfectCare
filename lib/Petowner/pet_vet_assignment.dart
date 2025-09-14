import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AssignVetToPetScreen extends StatefulWidget {
  const AssignVetToPetScreen({super.key});

  @override
  _AssignVetToPetScreenState createState() => _AssignVetToPetScreenState();
}

class _AssignVetToPetScreenState extends State<AssignVetToPetScreen> {
  String? selectedVetId;
  String? selectedVetName;
  String? selectedPetId;
  String? selectedPetName;

  List<QueryDocumentSnapshot> _vets = [];
  List<Map<String, dynamic>> _pets = [];

  bool _loadingVets = true;
  bool _loadingPets = true;

  @override
  void initState() {
    super.initState();
    _loadVets();
    _loadPets();
  }

  Future<void> _loadVets() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("role", isEqualTo: "Veterinarian")
          .get();

      setState(() {
        _vets = snapshot.docs;
        _loadingVets = false;
      });
    } catch (e) {
      print("Error fetching veterinarians: $e");
      setState(() => _loadingVets = false);
    }
  }

  Future<void> _loadPets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('pets')
          .orderByChild('ownerId')
          .equalTo(userId)
          .get();

      if (snapshot.value != null) {
        final petsMap = Map<dynamic, dynamic>.from(snapshot.value as Map);
        _pets = petsMap.entries.map((entry) {
          return {'id': entry.key, 'name': entry.value['name']};
        }).toList();
      } else {
        _pets = [];
      }
    } catch (e) {
      print("Error loading pets: $e");
      _pets = [];
    }

    setState(() => _loadingPets = false);
  }

  Future<void> _assignVetToPet() async {
    if (selectedVetId == null || selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both a vet and a pet")),
      );
      return;
    }

    try {
      final assignmentsRef = FirebaseDatabase.instance.ref('petAssignments');
      final newAssignmentRef = assignmentsRef.push();

      await newAssignmentRef.set({
        'vetId': selectedVetId,
        'vetName': selectedVetName,
        'petId': selectedPetId,
        'petName': selectedPetName,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vet assigned to pet")));
      Navigator.pop(context);
    } catch (e) {
      print("Error assigning vet: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to assign vet")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          "Assign Vet to Pet",
          style: TextStyle(color: Colors.white),
        ),

        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Choose a Veterinarian"),
            _buildVetDropdown(),
            const SizedBox(height: 20),
            _buildSectionTitle("Choose a Pet"),
            _buildPetDropdown(),
            const SizedBox(height: 40),
            _buildAssignButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black.withOpacity(0.8),
      ),
    );
  }

  Widget _buildVetDropdown() {
    if (_loadingVets) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No veterinarians available",
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }

    return Container(
      decoration: _dropdownDecoration(),
      child: DropdownButton<String>(
        value: selectedVetId,
        hint: const Text("Select a veterinarian"),
        isExpanded: true,
        onChanged: (val) {
          setState(() {
            selectedVetId = val;
            final vetDoc = _vets.firstWhere((d) => d.id == val);
            selectedVetName = (vetDoc.data() as Map<String, dynamic>)["name"];
          });
        },
        items: _vets.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return DropdownMenuItem<String>(
            value: doc.id,
            child: Text(data["name"] ?? "Unnamed"),
          );
        }).toList(),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
      ),
    );
  }

  Widget _buildPetDropdown() {
    if (_loadingPets) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No pets available",
          style: TextStyle(fontSize: 16, color: Colors.redAccent),
        ),
      );
    }

    return Container(
      decoration: _dropdownDecoration(),
      child: DropdownButton<String>(
        value: selectedPetId,
        hint: const Text("Select a pet"),
        isExpanded: true,
        onChanged: (val) {
          setState(() {
            selectedPetId = val;
            final selectedPet = _pets.firstWhere((p) => p['id'] == val);
            selectedPetName = selectedPet['name'];
          });
        },
        items: _pets.map((pet) {
          return DropdownMenuItem<String>(
            value: pet['id'],
            child: Text(pet['name'] ?? "Unnamed Pet"),
          );
        }).toList(),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
      ),
    );
  }

  Widget _buildAssignButton() {
    final isDisabled = _pets.isEmpty || _vets.isEmpty;

    return ElevatedButton(
      onPressed: isDisabled ? null : _assignVetToPet,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 5,
      ),
      child: const Text(
        "Assign Vet to Pet",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  BoxDecoration _dropdownDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
