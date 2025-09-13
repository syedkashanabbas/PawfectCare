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

  Map<DateTime, List<Map>> _events = {}; // store appointments by date

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final snapshot = await FirebaseDatabase.instance
        .ref('appointments')
        .orderByChild('vetId')
        .equalTo(userId)
        .get();

    if (snapshot.value != null) {
      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

      Map<DateTime, List<Map>> temp = {};

      for (var e in data.values) {
        final appt = Map<String, dynamic>.from(e);

        if (appt["date"] != null) {
          try {
            final date = DateTime.parse(appt["date"]);
            final dayKey = DateTime(date.year, date.month, date.day);

            temp.putIfAbsent(dayKey, () => []);
            temp[dayKey]!.add(appt);
          } catch (_) {}
        }
      }

      setState(() {
        _events = temp;
      });
    }
  }

  List<Map> _getEventsForDay(DateTime day) {
    final dayKey = DateTime(day.year, day.month, day.day);
    return _events[dayKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
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
            eventLoader: _getEventsForDay, // dots ayenge
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFF81C784),
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
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
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: (_getEventsForDay(_selectedDay ?? DateTime.now()))
                  .map((data) {
                final petName = data["petName"] ?? "Pet";
                final ownerName = data["ownerName"] ?? "Owner";
                final status = data["status"] ?? "Pending";
                final time = data["time"] ?? "";

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/pet.jpg"),
                    ),
                    title: Text(
                      "$petName • $time",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Owner: $ownerName • Status: $status"),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
