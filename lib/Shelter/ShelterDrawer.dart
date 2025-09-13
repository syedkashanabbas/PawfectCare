import 'package:flutter/material.dart';

class ShelterDrawer extends StatelessWidget {
  const ShelterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE8F5E9), // Light green theme
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50), // Green
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.pets, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text("Shelter Admin",
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          _buildItem(context, Icons.dashboard, 'Dashboard', '/shelterdashboard'),
          _buildItem(context, Icons.pets, 'All Pet Listing', '/petlisting'),
          _buildItem(context, Icons.add_box, 'Add Adoption Pets', '/add_editlisting'),
          _buildItem(context, Icons.article, 'Adoption Pet List', '/admin_petlisting'),
          _buildItem(context, Icons.assignment_ind, 'Adoption Requests', '/adoption'),
          _buildItem(context, Icons.emoji_emotions, 'Success Stories', '/successstory'),
          _buildItem(context, Icons.edit_note, 'Add Story', '/addstory'),
          _buildItem(context, Icons.volunteer_activism, 'Volunteer Form', '/volunteer'),
          _buildItem(context, Icons.attach_money, 'Donation Form', '/donation'),
          _buildItem(context, Icons.volunteer_activism, 'Volunteers List', '/volunteerlist'),
          _buildItem(context, Icons.attach_money, 'Donations List', '/donationlist'),
          _buildItem(context, Icons.article, 'Add Blog', '/add_editblog'),
          _buildItem(context, Icons.article, 'Blogs', '/bloglistshelter'),
          _buildItem(context, Icons.notification_add_outlined, 'Notifications', '/admin_notifications'),

          const Divider(),
          _buildItem(context, Icons.logout, 'Logout', '/login'),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pushNamed(route);
      },
    );
  }
}
