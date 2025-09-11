import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Appointment Reminder',
        'message': 'You have an appointment with Dr. Sana tomorrow at 10:00 AM.',
        'icon': Icons.calendar_today,
        'date': 'Sep 12, 2025',
      },
      {
        'title': 'New Adoption Request',
        'message': 'A user has requested to adopt Bella.',
        'icon': Icons.pets,
        'date': 'Sep 11, 2025',
      },
      {
        'title': 'Vaccination Due',
        'message': 'Tommy’s rabies vaccine is due next week.',
        'icon': Icons.vaccines,
        'date': 'Sep 10, 2025',
      },
      {
        'title': 'Blog Published',
        'message': 'A new blog on pet nutrition is now available.',
        'icon': Icons.article,
        'date': 'Sep 08, 2025',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF4CAF50),
                child: Icon(item['icon'], color: Colors.white),
              ),
              title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['message']),
              trailing: Text(item['date'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
