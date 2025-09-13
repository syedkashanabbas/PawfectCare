import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: userId == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref("notifications/$userId")
            .orderByChild("createdAt")
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No notifications yet"));
          }

          final raw = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final notifs = raw.entries.map((entry) {
            final data = Map<String, dynamic>.from(entry.value);
            data["id"] = entry.key;
            return data;
          }).toList();

          // sort latest first
          notifs.sort((a, b) =>
              (b["createdAt"] ?? "").toString().compareTo((a["createdAt"] ?? "").toString()));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final item = notifs[index];
              final isRead = item["read"] == true;
              final ts = item["createdAt"];
              String formattedDate = "";
              if (ts != null) {
                try {
                  final dt = DateTime.tryParse(ts.toString());
                  if (dt != null) {
                    formattedDate = DateFormat("MMM dd, yyyy").format(dt);
                  }
                } catch (_) {}
              }

              return GestureDetector(
                onTap: () {
                  FirebaseDatabase.instance
                      .ref("notifications/$userId")
                      .child(item["id"])
                      .update({"read": true});
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Icon(
                        isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item['title'] ?? "Notification",
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(item['message'] ?? ""),
                    trailing: Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
