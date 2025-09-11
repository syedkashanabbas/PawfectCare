import 'package:flutter/material.dart';

class AdoptionRequestsScreen extends StatelessWidget {
  const AdoptionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> adoptionRequests = [
      {
        'petName': 'Tommy',
        'adopter': 'Ali Raza',
        'status': 'Pending',
        'date': '2025-09-10',
      },
      {
        'petName': 'Bella',
        'adopter': 'Ayesha Khan',
        'status': 'Approved',
        'date': '2025-09-08',
      },
      {
        'petName': 'Max',
        'adopter': 'Usman Tariq',
        'status': 'Rejected',
        'date': '2025-09-06',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Adoption Requests', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: adoptionRequests.length,
        itemBuilder: (context, index) {
          final req = adoptionRequests[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pet: ${req['petName']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Adopter: ${req['adopter']}"),
                  Text("Requested On: ${req['date']}"),
                  Text("Status: ${req['status']}", style: TextStyle(
                    color: req['status'] == 'Approved'
                        ? Colors.green
                        : req['status'] == 'Rejected'
                        ? Colors.red
                        : Colors.orange,
                  )),
                  const SizedBox(height: 10),
                  if (req['status'] == 'Pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Reject logic (to be implemented)
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text("Reject", style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Approve logic (to be implemented)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                          child: const Text("Approve"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
