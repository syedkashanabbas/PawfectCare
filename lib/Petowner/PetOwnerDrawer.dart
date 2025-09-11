import 'package:flutter/material.dart';

class PetOwnerDrawer extends StatelessWidget {
  const PetOwnerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFEFFAF0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/pet_owner.png"),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome, Pet Owner!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          _drawerItem(context, Icons.dashboard, 'Dashboard', '/petownerdashboard'),
          _drawerItem(context, Icons.pets, 'Add/Edit Pet Profile', '/add_edit'),
          _drawerItem(context, Icons.medical_services, 'Pet Health', '/pethealth'),
          _drawerItem(context, Icons.calendar_today, 'Book Appointment', '/appointment'),
          _drawerItem(context, Icons.history, 'Appointment History', '/appointmenthistory'),
          _drawerItem(context, Icons.store, 'Pet Store', '/petstore'),
          _drawerItem(context, Icons.article, 'Blogs', '/bloglist'),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
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
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
