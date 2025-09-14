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

  // Predefined time slots for the calendar
  final List<String> timeSlots = ['9:30', '10:30', '11:30', '3:30', '4:30', '5:30'];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // Load appointments for the current vet from Firebase
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

      // Iterate through the data and directly use Firebase key (document ID) as 'id'
      for (var key in data.keys) {  // 'key' is the Firebase-generated document ID for each appointment
        final appt = Map<String, dynamic>.from(data[key]);

        // Directly use the Firebase document ID as the appointment ID
        appt['id'] = key;  // Adding the document ID to the appointment data

        if (appt["date"] != null) {
          try {
            final date = DateTime.parse(appt["date"]);
            final dayKey = DateTime(date.year, date.month, date.day);

            temp.putIfAbsent(dayKey, () => []);
            temp[dayKey]!.add(appt);
          } catch (_) {
            // Handle the date parsing failure if needed
          }
        }
      }

      // Update the state with the new appointment data
      setState(() {
        _events = temp;
      });
    }
  }

  // Update the status of an appointment in Firebase
  Future<void> _updateAppointmentStatus(String appointmentId, String status) async {
    final appointmentRef = FirebaseDatabase.instance.ref('appointments/$appointmentId');
    await appointmentRef.update({'status': status});
  }

  // Reschedule an appointment by updating the date and time
  Future<void> _rescheduleAppointment(String appointmentId, DateTime newDateTime) async {
    final appointmentRef = FirebaseDatabase.instance.ref('appointments/$appointmentId');
    await appointmentRef.update({
      'date': newDateTime.toIso8601String(),
      'time': "${newDateTime.hour}:${newDateTime.minute}",
    });
  }

  // Handle approval, rejection, or rescheduling
  _handleAppointmentAction(Map appointmentData, String action) async {
    final appointmentId = appointmentData['id'];
    if (appointmentId == null || appointmentId.isEmpty) {
      print('Error: Appointment ID is null or empty');
      return;
    }

    String? statusMessage;
    Map<DateTime, List<Map>> updatedEvents = Map.from(_events);

    if (action == 'approve') {
      await _updateAppointmentStatus(appointmentId, 'Upcoming');
      statusMessage = "The appointment has been approved and is now upcoming.";

      _updateEventStatusInMap(appointmentId, 'Upcoming', updatedEvents);
    } else if (action == 'reject') {
      await _updateAppointmentStatus(appointmentId, 'Cancelled');
      statusMessage = "The appointment has been cancelled.";

      _updateEventStatusInMap(appointmentId, 'Cancelled', updatedEvents);
    } else if (action == 'reschedule') {
      // Prompt user for a new date/time to reschedule
      DateTime? newDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (newDate != null) {
        // Show the available time slots for rescheduling
        TimeOfDay? newTime = await showTimeSlotPicker(context);

        if (newTime != null) {
          DateTime newDateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);

          // Reschedule the appointment with the new date/time
          await _rescheduleAppointment(appointmentId, newDateTime);
          await _updateAppointmentStatus(appointmentId, 'Rescheduled');

          statusMessage = "The appointment for ${appointmentData['petName']} has been rescheduled to ${newDateTime.toLocal().toString()}";

          _updateEventStatusInMap(appointmentId, 'Rescheduled', updatedEvents, newDateTime);
        }
      }
    }

    // Show the status change prompt to the doctor
    if (statusMessage != null) {
      _showStatusChangeDialog(statusMessage);
    }

    // Update the UI with the modified events
    setState(() {
      _events = updatedEvents;
    });
  }

  // Helper function to update the event status in the _events map
  void _updateEventStatusInMap(String appointmentId, String status, Map<DateTime, List<Map>> events, [DateTime? newDateTime]) {
    for (var day in events.keys) {
      var appointments = events[day];
      for (var appt in appointments!) {
        if (appt['id'] == appointmentId) {
          appt['status'] = status;
          if (newDateTime != null) {
            appt['date'] = newDateTime.toIso8601String();
            appt['time'] = "${newDateTime.hour}:${newDateTime.minute}";
          }
        }
      }
    }
  }

  // Show a dialog to inform the vet about the status change
  void _showStatusChangeDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Appointment Status"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show time slot picker dialog with limited slots
  Future<TimeOfDay?> showTimeSlotPicker(BuildContext context) {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Time Slot"),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeSlots.map((time) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(TimeOfDay(hour: int.parse(time.split(":")[0]), minute: int.parse(time.split(":")[1])));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      time,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog without selecting
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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
            eventLoader: _getEventsForDay, // dots for events
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
                final appointmentId = data['id'] ?? ''; // Add this field to identify the appointment

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
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        _handleAppointmentAction(data, action);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(value: 'approve', child: Text('Approve')),
                        const PopupMenuItem<String>(value: 'reject', child: Text('Reject')),
                        const PopupMenuItem<String>(value: 'reschedule', child: Text('Reschedule')),
                      ],
                    ),
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
