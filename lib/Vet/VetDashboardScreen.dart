import 'package:flutter/material.dart';

class VetDashboardScreen extends StatelessWidget {
  const VetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0), // light green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        title: const Text(
          'Welcome, Dr. Kashan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Today's Appointments"),
              _appointmentCard("Tommy", "10:00 AM", "John Doe"),
              _appointmentCard("Milo", "12:30 PM", "Sara Khan"),
              const SizedBox(height: 20),
              _sectionTitle("Assigned Pets"),
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _petCard(
                      "Bella",
                      "Golden Retriever",
                      "2y",
                      "assets/pet.jpg",
                    ),
                    _petCard("Max", "Pug", "5y", "assets/pet2.png"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _sectionTitle("Quick Actions"),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionButton(Icons.add_chart, "Add Diagnosis"),
                  _actionButton(Icons.upload_file, "Upload Files"),
                  _actionButton(Icons.calendar_today, "Calendar"),
                  _actionButton(Icons.edit, "Write Blog"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _appointmentCard(String pet, String time, String owner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/pet.jpg"),
        ),
        title: Text("$pet - $time"),
        subtitle: Text("Owner: $owner"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _petCard(String name, String breed, String age, String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 28, backgroundImage: AssetImage(imagePath)),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(breed, style: const TextStyle(fontSize: 12)),
          Text(age, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
