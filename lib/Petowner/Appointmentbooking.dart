import 'package:flutter/material.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  String? selectedTime;

  final List<String> timeSlots = [
    '9:30', '10:30',
    '11:30', '3:30',
    '4:30', '5:30',
  ];

  @override
  Widget build(BuildContext context) {
    final greenColor = Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        leading: const BackButton(color: Colors.white),
        title: const Text("Dr. Nambuvan", style: TextStyle(color: Colors.white)),
      ),
      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text("Choose a Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              padding: const EdgeInsets.all(8),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                onDateChanged: (date) => setState(() => selectedDate = date),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Pick a Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: timeSlots.map((time) {
                final isSelected = time == selectedTime;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  selectedColor: greenColor,
                  onSelected: (_) => setState(() => selectedTime = time),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                if (selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a time slot")),
                  );
                  return;
                }

                // TODO: Handle appointment booking logic
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text("Book an Appointment"),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          ],
        ),
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      currentIndex: 3, // Manage tab
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Manage'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
