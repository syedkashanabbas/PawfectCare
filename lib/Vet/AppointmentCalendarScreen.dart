import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('My Calendar', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2023),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
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
            const SizedBox(height: 20),
            Row(
              children: const [
                Text(
                  "Scheduled Appointments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _appointmentCard("Tommy", "10:00 AM", "John Doe"),
            _appointmentCard("Milo", "1:30 PM", "Sara Ali"),
            _appointmentCard("Bruno", "3:00 PM", "Ali Khan"),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard(String pet, String time, String owner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/pet.jpg"), // Placeholder image
        ),
        title: Text("$pet - $time"),
        subtitle: Text("Owner: $owner"),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Placeholder for actions (Confirm/Cancel)
          },
        ),
      ),
    );
  }
}
