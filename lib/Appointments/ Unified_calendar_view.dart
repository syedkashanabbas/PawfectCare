import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class UnifiedCalendarView extends StatefulWidget {
  const UnifiedCalendarView({super.key});

  @override
  State<UnifiedCalendarView> createState() => _UnifiedCalendarViewState();
}

class _UnifiedCalendarViewState extends State<UnifiedCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> appointments = {
    DateTime.utc(2025, 9, 15): ['Vaccination - Bella'],
    DateTime.utc(2025, 9, 17): ['Surgery - Max', 'Follow-up - Luna'],
    DateTime.utc(2025, 9, 20): ['Grooming - Charlie'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        title: const Text("Appointments Calendar", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF81C784),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text("Select a date to view appointments"))
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Appointments on ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._getEventsForDay(_selectedDay!).map((event) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.pets, color: Color(0xFF4CAF50)),
                      title: Text(event),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
