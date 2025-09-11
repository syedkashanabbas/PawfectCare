import 'package:flutter/material.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  final Color greenColor = const Color(0xFF4CAF50);

  AppointmentHistoryScreen({super.key});

  final List<Map<String, String>> pastAppointments = [
    {
      "doctor": "Dr. Nambuvan",
      "date": "24 Jan 2022",
      "time": "11:30 AM",
      "status": "Completed",
    },
    {
      "doctor": "Dr. Raam",
      "date": "12 Feb 2022",
      "time": "03:30 PM",
      "status": "Cancelled",
    },
    {
      "doctor": "Dr. Jerry",
      "date": "05 Mar 2022",
      "time": "10:00 AM",
      "status": "Completed",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        leading: const BackButton(color: Colors.white),
        title: const Text("Appointment History", style: TextStyle(color: Colors.white)),
      ),
      drawer: const PetOwnerDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastAppointments.length,
        itemBuilder: (context, index) {
          final appt = pastAppointments[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                appt["doctor"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text("Date: ${appt["date"]}"),
                  Text("Time: ${appt["time"]}"),
                  const SizedBox(height: 6),
                  _buildStatusChip(appt["status"]!),
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _buildStatusChip(String status) {
    final isCompleted = status.toLowerCase() == 'completed';
    final isCancelled = status.toLowerCase() == 'cancelled';

    return Chip(
      label: Text(status),
      backgroundColor: isCompleted
          ? Colors.green.shade100
          : isCancelled
          ? Colors.red.shade100
          : Colors.grey.shade300,
      labelStyle: TextStyle(
        color: isCompleted
            ? Colors.green.shade800
            : isCancelled
            ? Colors.red.shade800
            : Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: greenColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Manage"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
