import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pawfectcare/auth_service.dart';

class VetDashboardScreen extends StatefulWidget {
  const VetDashboardScreen({super.key});

  @override
  State<VetDashboardScreen> createState() => _VetDashboardScreenState();
}

class _VetDashboardScreenState extends State<VetDashboardScreen> {
  String? selectedPetId;
  DateTime? selectedDate;
  List<Map<String, dynamic>> petList = [];

  @override
  void initState() {
    super.initState();
    _loadAppointedPets();
  }

  /// ✅ Sirf un pets ko load kare jo appointments me aaye hain
  Future<void> _loadAppointedPets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final apptSnapshot = await FirebaseDatabase.instance
        .ref("appointments")
        .orderByChild("vetId")
        .equalTo(userId)
        .get();

    if (apptSnapshot.value == null) return;

    final appointments =
        Map<dynamic, dynamic>.from(apptSnapshot.value as Map);

    // Unique petIds collect karna
    final petIds = appointments.values
        .map((e) => (e as Map)["petId"])
        .where((id) => id != null)
        .toSet();

    final List<Map<String, dynamic>> pets = [];

    for (var petId in petIds) {
      final petSnap =
          await FirebaseDatabase.instance.ref("adminpets/$petId").get();
      if (petSnap.value != null) {
        final pet = Map<String, dynamic>.from(petSnap.value as Map);
        pet["id"] = petId;
        pets.add(pet);
      }
    }

    setState(() {
      petList = pets;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedDate = null;
      selectedPetId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Welcome, Vet");
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return Text("Welcome, Dr. ${data["name"] ?? "Veterinarian"}");
          },
        ),
      ),
      drawer: const VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Filter Appointments"),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
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
                    child: Text(
                      selectedDate == null
                          ? "Select Date"
                          : DateFormat("yyyy-MM-dd").format(selectedDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedPetId,
                    decoration: const InputDecoration(
                      labelText: "Select Pet",
                      border: OutlineInputBorder(),
                    ),
                    items: petList.map((pet) {
                      final id = pet["id"];
                      final label =
                          "${pet["name"] ?? "Unknown"} (${pet["breed"] ?? ""})";
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedPetId = val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, color: Colors.red),
                  tooltip: "Reset Filters",
                ),
              ],
            ),

            const SizedBox(height: 10),
            _sectionTitle("Appointments"),

            Expanded(
              child: StreamBuilder(
                stream: FirebaseDatabase.instance
                    .ref("appointments")
                    .orderByChild("vetId")
                    .equalTo(userId)
                    .onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Text("No appointments found");
                  }

                  final data = Map<dynamic, dynamic>.from(
                      snapshot.data!.snapshot.value as Map);

                  // Apply filters
                  final filteredAppointments = data.values.where((e) {
                    final appt = Map<String, dynamic>.from(e);

                    // filter by date
                    if (selectedDate != null && appt["date"] != null) {
                      try {
                        final apptDate = DateTime.parse(appt["date"]);
                        if (DateFormat("yyyy-MM-dd").format(apptDate) !=
                            DateFormat("yyyy-MM-dd").format(selectedDate!)) {
                          return false;
                        }
                      } catch (_) {}
                    }

                    // filter by pet
                    if (selectedPetId != null && selectedPetId!.isNotEmpty) {
                      if ((appt["petId"] ?? "") != selectedPetId) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  if (filteredAppointments.isEmpty) {
                    return const Text("No matching appointments");
                  }

                  return ListView(
                    children: filteredAppointments.map((e) {
                      final appt = Map<String, dynamic>.from(e);
                      return _appointmentCard(
                        appt["petName"] ?? "Unknown",
                        appt["time"] ?? "N/A",
                        appt["date"] ?? "",
                        appt["ownerId"] ?? "",
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _appointmentCard(String pet, String time, String date, String ownerId) {
    final formattedDate = date.isNotEmpty
        ? DateFormat("yyyy-MM-dd").format(DateTime.parse(date))
        : "N/A";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
            backgroundImage: AssetImage("assets/pet.jpg")),
        title: Text("$pet - $time"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $formattedDate"),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(ownerId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text("Owner: Unknown");
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return Text("Owner: ${data["name"] ?? "Unknown"}");
              },
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class VetDrawer extends StatelessWidget {
  const VetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Drawer(
      backgroundColor: const Color(0xFFEFFAF0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
            builder: (context, snapshot) {
              String name = "Vet";
              String email = "";
              String imageUrl = "";
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                name = data["name"] ?? "Vet";
                email = data["email"] ?? "";
                imageUrl = data["profileImage"] ?? "";
              }
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
              );
            },
          ),
          _drawerItem(context, Icons.dashboard, 'Dashboard', '/vetdashboard'),
          _drawerItem(context, Icons.calendar_today, 'Appointments', '/appointmentcalendar'),
          _drawerItem(context, Icons.pets, 'Patients', '/vetPatients'),
          _drawerItem(context, Icons.article, 'Blogs', '/vetBlogs'),
          _drawerItem(context, Icons.settings, 'Profile Settings', '/vetProfile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, "/login", (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
