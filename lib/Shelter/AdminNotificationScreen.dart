import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('All Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref("notifications").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No notifications available"));
          }

          final raw = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final List<Map<String, dynamic>> allNotifs = [];

          // Each userId has its own notifications
          raw.forEach((userId, userNotifs) {
            final userMap = Map<dynamic, dynamic>.from(userNotifs);
            userMap.forEach((notifId, notifData) {
              final n = Map<String, dynamic>.from(notifData);
              n["id"] = notifId;
              n["userId"] = userId;
              allNotifs.add(n);
            });
          });

          // sort by createdAt desc
          allNotifs.sort((a, b) =>
              (b["createdAt"] ?? "").toString().compareTo((a["createdAt"] ?? "").toString()));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allNotifs.length,
            itemBuilder: (context, index) {
              final item = allNotifs[index];
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

              return Card(
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
                  onTap: () {
                    // mark read
                    FirebaseDatabase.instance
                        .ref("notifications/${item["userId"]}")
                        .child(item["id"])
                        .update({"read": true});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
