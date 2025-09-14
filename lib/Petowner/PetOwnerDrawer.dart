import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetOwnerDrawer extends StatelessWidget {
  const PetOwnerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: const Color(0xFFEFFAF0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text(
                    "Welcome, User!",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  );
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final name = data["name"] ?? "User";
                final imageUrl = data["profileImage"] ?? "";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Welcome, $name!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          _drawerItem(context, Icons.dashboard, 'Dashboard', '/petownerdashboard'),
          _drawerItem(context, Icons.notification_add, 'Notifications', '/notification'),
          _drawerItem(context, Icons.pets, 'Add Pet Profile', '/add_edit'),
          _drawerItem(context, Icons.medical_services, 'Pet Health', '/pethealth'),
          _drawerItem(context, Icons.calendar_today, 'Book Appointment', '/appointment'),
          _drawerItem(context, Icons.history, 'Appointment History', '/appointmenthistory'),
          _drawerItem(context, Icons.store, 'Pet Store', '/petstore'),
          _drawerItem(context, Icons.store, 'Available Pets', '/availablepets'),
          _drawerItem(context, Icons.article, 'Blogs', '/bloglist'),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
