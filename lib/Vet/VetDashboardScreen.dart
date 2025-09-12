import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectcare/auth_service.dart';

class VetDashboardScreen extends StatelessWidget {
  const VetDashboardScreen({super.key});

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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Welcome...");
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("Welcome, Vet");
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data["name"] ?? "Veterinarian";
            return Text(
              "Welcome, Dr. $name",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
      ),
      drawer: const VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Today's Appointments"),
              _appointmentCard("Tommy", "10:00 AM", "John Doe"),
              _appointmentCard("Milo", "12:30 PM", "Sara Khan"),
              const SizedBox(height: 20),
              _sectionTitle("Assigned Pets"),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _petCard("Bella", "Golden Retriever", "2y", "assets/pet.jpg"),
                    _petCard("Max", "Pug", "5y", "assets/pet2.png"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle("Quick Actions"),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionButton(Icons.pending_actions, "Pending Appts", () {
                    Navigator.pushNamed(context, "/vetPendingAppointments");
                  }),
                  _actionButton(Icons.upcoming, "Upcoming Appts", () {
                    Navigator.pushNamed(context, "/vetUpcomingAppointments");
                  }),
                  _actionButton(Icons.pets, "Patients", () {
                    Navigator.pushNamed(context, "/vetPatients");
                  }),
                  _actionButton(Icons.article, "Blogs", () {
                    Navigator.pushNamed(context, "/vetBlogs");
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _appointmentCard(String pet, String time, String owner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/pet.jpg"),
        ),
        title: Text("$pet - $time"),
        subtitle: Text("Owner: $owner"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _petCard(String name, String breed, String age, String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 28, backgroundImage: AssetImage(imagePath)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(breed, style: const TextStyle(fontSize: 12)),
          Text(age, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
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
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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