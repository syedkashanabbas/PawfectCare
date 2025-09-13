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
  List<Map<String, dynamic>> petList = [];

  @override
  void initState() {
    super.initState();
    _loadAppointedPets();
  }

  Future<void> _loadAppointedPets() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final apptSnapshot = await FirebaseDatabase.instance
        .ref("appointments")
        .orderByChild("vetId")
        .equalTo(userId)
        .get();

    if (apptSnapshot.value == null) return;

    final appointments = Map<dynamic, dynamic>.from(apptSnapshot.value as Map);

    final petIds = appointments.values
        .map((e) => (e as Map)["petId"])
        .where((id) => id != null)
        .toSet();

    final List<Map<String, dynamic>> pets = [];

    for (var petId in petIds) {
      final petSnap =
      await FirebaseDatabase.instance.ref("pets/$petId").get();
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
        actions: [
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref("notifications/$userId")
                .orderByChild("createdAt")
                .limitToLast(5)
                .onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              }

              final notifs = <Map<String, dynamic>>[];
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final raw = Map<dynamic, dynamic>.from(
                  snapshot.data!.snapshot.value as Map,
                );
                raw.forEach((key, value) {
                  final n = Map<String, dynamic>.from(value);
                  n["id"] = key;
                  notifs.add(n);
                });
                notifs.sort((a, b) => (b["createdAt"] ?? "")
                    .toString()
                    .compareTo((a["createdAt"] ?? "").toString()));
              }

              return PopupMenuButton<Map<String, dynamic>>(
                icon: const Icon(Icons.notifications, color: Colors.white),
                itemBuilder: (ctx) {
                  if (notifs.isEmpty) {
                    return [
                      const PopupMenuItem(
                        child: Text("No notifications"),
                      )
                    ];
                  }
                  return notifs.map((n) {
                    final read = n["read"] == true;
                    return PopupMenuItem<Map<String, dynamic>>(
                      value: n,
                      child: ListTile(
                        leading: Icon(
                          read ? Icons.notifications_none : Icons.notifications_active,
                          color: Colors.green[700],
                        ),
                        title: Text(
                          n["title"] ?? "Notification",
                          style: TextStyle(
                            fontWeight: read ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(n["message"] ?? ""),
                      ),
                    );
                  }).toList();
                },
                onSelected: (notif) {
                  FirebaseDatabase.instance
                      .ref("notifications/$userId")
                      .child(notif["id"])
                      .update({"read": true});
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
            onPressed: () async {
              await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
              }
            },
          ),
        ],
      ),
      drawer: const VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Filter Appointments"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: DropdownButtonFormField<String>(
                      value: selectedPetId,
                      decoration: InputDecoration(
                        labelText: "Select Pet",
                        labelStyle: const TextStyle(fontSize: 16, color: Colors.green),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      items: petList.map((pet) {
                        final id = pet["id"];
                        final label = "${pet["name"] ?? "Unknown"}";
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
                  if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                    return const Text("No appointments found");
                  }

                  final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);

                  final now = DateTime.now();
                  final todayStart = DateTime(now.year, now.month, now.day);
                  final todayEnd = todayStart.add(const Duration(days: 1));

                  final filteredAppointments = data.values.where((e) {
                    final appt = Map<String, dynamic>.from(e);
                    if (appt["date"] != null) {
                      try {
                        final apptDate = DateTime.parse(appt["date"]);
                        if (apptDate.isBefore(todayStart) || apptDate.isAfter(todayEnd)) {
                          return false;
                        }
                      } catch (_) {}
                    }
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
                        appt["status"] ?? "",
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
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4CAF50),
        ),
      ),
    );
  }

  Widget _appointmentCard(String pet, String time, String date, String ownerId, String status) {
    final formattedDate = date.isNotEmpty
        ? DateFormat("yyyy-MM-dd").format(DateTime.parse(date))
        : "N/A";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      child: ListTile(
        leading: const CircleAvatar(backgroundImage: AssetImage("assets/pet.jpg")),
        title: Text("$pet - $time", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $formattedDate"),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection("users").doc(ownerId).get(),
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.green),
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
          _drawerItem(context, Icons.article, 'Blogs', '/bloglist'),
          _drawerItem(context, Icons.settings, 'Notifications', '/notification'),
          _drawerItem(context, Icons.settings, 'Profile Settings', '/userprofile'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
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
