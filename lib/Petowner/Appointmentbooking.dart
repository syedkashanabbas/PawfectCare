import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String? selectedVetId;
  String? selectedVetName;
  String? selectedPetId;
  String? selectedPetName;

  final List<String> timeSlots = [
    '9:30', '10:30', '11:30', '3:30', '4:30', '5:30',
  ];

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("appointments");
  final DatabaseReference notifRef = FirebaseDatabase.instance.ref("notifications");

  @override
  Widget build(BuildContext context) {
    final greenColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        leading: const BackButton(color: Colors.white),
        title: const Text("Book Appointment", style: TextStyle(color: Colors.white)),
      ),
      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose a Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("role", isEqualTo: "Veterinarian")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final vets = snapshot.data!.docs;
                if (vets.isEmpty) return const Text("No doctors available.");
                return DropdownButtonFormField<String>(
                  value: selectedVetId,
                  items: vets.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data["name"] ?? "Unnamed"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedVetId = val;
                      final vetDoc = vets.firstWhere((d) => d.id == val);
                      selectedVetName = (vetDoc.data() as Map<String, dynamic>)["name"];
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  hint: const Text("Select a veterinarian"),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text("Choose a Pet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Fetch pets
            StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('pets')
                  .orderByChild('ownerId')
                  .equalTo(FirebaseAuth.instance.currentUser?.uid)
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No pets found"));
                }

                final petsMap = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
                final petList = petsMap.entries.map((entry) {
                  return {
                    'id': entry.key,
                    'name': entry.value['name'],
                  };
                }).toList();

                return DropdownButtonFormField<String>(
                  value: selectedPetId,
                  items: petList.map<DropdownMenuItem<String>>((pet) {
                    final petId = pet['id'] as String;
                    final petName = pet['name'] as String;

                    return DropdownMenuItem<String>(
                      value: petId,
                      child: Text(petName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedPetId = val;
                      final selectedPet = petList.firstWhere((p) => p['id'] == val);
                      selectedPetName = selectedPet['name'];
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  hint: const Text("Select a pet"),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text("Choose a Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) => setState(() => selectedDate = date),
            ),

            const SizedBox(height: 20),
            const Text("Pick a Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: timeSlots.map((time) {
                final isSelected = time == selectedTime;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  selectedColor: greenColor,
                  onSelected: (_) => setState(() => selectedTime = time),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _bookAppointment,
              icon: const Icon(Icons.calendar_today),
              label: const Text("Book an Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Future<void> _bookAppointment() async {
    if (selectedVetId == null || selectedVetName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a doctor")));
      return;
    }
    if (selectedPetId == null || selectedPetName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a pet")));
      return;
    }
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a time slot")));
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final appointmentData = {
      "ownerId": userId,
      "vetId": selectedVetId,
      "vetName": selectedVetName,
      "petId": selectedPetId,
      "petName": selectedPetName,
      "date": selectedDate.toIso8601String(),
      "time": selectedTime,
      "status": "pending",
      "createdAt": DateTime.now().toIso8601String(),
    };

    final newRef = await dbRef.push();
    await newRef.set(appointmentData);

    // Notifications
    final ownerMessage = "Your appointment with Dr. $selectedVetName is on ${selectedDate.toLocal().toString().split(' ')[0]} at $selectedTime.";
    final vetMessage = "You have an appointment with $selectedPetName on ${selectedDate.toLocal().toString().split(' ')[0]} at $selectedTime.";

    await notifRef.child(userId).push().set({
      "title": "Appointment Booked",
      "message": ownerMessage,
      "read": false,
      "appointmentId": newRef.key,
      "createdAt": DateTime.now().toIso8601String(),
    });

    await notifRef.child(selectedVetId!).push().set({
      "title": "New Appointment",
      "message": vetMessage,
      "read": false,
      "appointmentId": newRef.key,
      "createdAt": DateTime.now().toIso8601String(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked & notifications sent!")),
      );
      Navigator.pop(context);
    }
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      currentIndex: 3,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Manage'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
