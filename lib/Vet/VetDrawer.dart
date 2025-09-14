import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectcare/auth_service.dart';

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
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(userId)
                .get(),
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
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 40)
                      : null,
                ),
              );
            },
          ),
          _drawerItem(context, Icons.dashboard, 'Dashboard', '/vetdashboard'),
          _drawerItem(context, Icons.shop_2_outlined, 'Shop', '/storelist'),
          _drawerItem(
            context,
            Icons.calendar_today,
            'Appointments',
            '/appointmentcalendar',
          ),

          _drawerItem(context, Icons.article, 'Blogs', '/bloglist'),
          _drawerItem(
            context,
            Icons.settings,
            'Notifications',
            '/notification',
          ),
          _drawerItem(
            context,
            Icons.settings,
            'Profile Settings',
            '/userprofile',
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await AuthService().logoutUser();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
