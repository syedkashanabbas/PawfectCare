import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AppointmentCalendarScreen extends StatefulWidget {
  const AppointmentCalendarScreen({super.key});

  @override
  State<AppointmentCalendarScreen> createState() =>
      _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends State<AppointmentCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Appointments', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF81C784),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('appointments')
                  .orderByChild('vetId')
                  .equalTo(userId)
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If no data found
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("No appointments found"));
                }

                final appointmentsMap =
                Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);

                final docs = appointmentsMap.values.where((doc) {
                  if (_selectedDay == null) return true;
                  final date = DateTime.parse(doc["date"]);
                  return date.year == _selectedDay!.year &&
                      date.month == _selectedDay!.month &&
                      date.day == _selectedDay!.day;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No appointments on this day"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final petName = data["petName"] ?? "Pet";
                    final ownerName = data["ownerName"] ?? "Owner";
                    final status = data["status"] ?? "Pending";
                    final date = DateTime.parse(data["date"]);
                    final time = data["time"] ?? "";
                    final appointmentId = snapshot.data!.snapshot.children.elementAt(index).key;

                    // Safety check for null values
                    if (appointmentId == null || status == null) {
                      return const SizedBox.shrink(); // Skip invalid data
                    }

                    // Debugging Logs:
                    print("Appointment ID: $appointmentId, Status: $status");

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage("assets/pet.jpg"), // placeholder
                        ),
                        title: Text(
                          "$petName • $time",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Owner: $ownerName"),
                            Text(
                              "Date: ${date.day}-${date.month}-${date.year}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            _statusChip(status),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == "Approve") {
                              FirebaseDatabase.instance
                                  .ref('appointments')
                                  .child(appointmentId)
                                  .update({"status": "Upcoming"}).then((_) {
                                print('Appointment Approved');
                              }).catchError((error) {
                                print('Error: $error');
                              });
                            } else if (value == "Cancel") {
                              FirebaseDatabase.instance
                                  .ref('appointments')
                                  .child(appointmentId)
                                  .update({"status": "Cancelled"}).then((_) {
                                print('Appointment Cancelled');
                              }).catchError((error) {
                                print('Error: $error');
                              });
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: "Approve", child: Text("Approve")),
                            const PopupMenuItem(value: "Cancel", child: Text("Cancel")),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case "pending":
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        break;
      case "upcoming":
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        break;
      case "completed":
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        break;
      case "cancelled":
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.black;
    }
    return Chip(
      label: Text(status),
      backgroundColor: bg,
      labelStyle: TextStyle(color: fg, fontWeight: FontWeight.bold),
    );
  }
}
