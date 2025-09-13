import 'package:firebase_database/firebase_database.dart';

final DatabaseReference _notifRef = FirebaseDatabase.instance.ref("notifications");

Future<void> sendNotification({
  required String userId,
  required String title,
  required String message,
  Map<String, dynamic>? extraInfo,
}) async {
  await _notifRef.child(userId).push().set({
    "title": title,
    "message": message,
    "extraInfo": extraInfo ?? {},
    "createdAt": DateTime.now().toIso8601String(),
    "read": false,
  });
}
