import 'package:flutter/material.dart';

class AppointmentDetailsScreen extends StatelessWidget {
  final String petName;
  final String ownerName;
  final String dateTime;
  final String doctor;
  final String notes;

  const AppointmentDetailsScreen({
    super.key,
    this.petName = "Bella",
    this.ownerName = "Ali Khan",
    this.dateTime = "Sept 15, 2025 – 10:30 AM",
    this.doctor = "Dr. Kashan",
    this.notes = "Vaccination for annual boosters.",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FFF4),
      appBar: AppBar(
        title: const Text("Appointment Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: "Pet Name", value: petName),
                const Divider(),
                DetailRow(label: "Owner", value: ownerName),
                const Divider(),
                DetailRow(label: "Date & Time", value: dateTime),
                const Divider(),
                DetailRow(label: "Doctor", value: doctor),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  "Notes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  notes,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}
