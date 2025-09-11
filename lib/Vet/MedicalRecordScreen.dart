import 'package:flutter/material.dart';

class MedicalRecordScreen extends StatelessWidget {
  const MedicalRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> medicalHistory = [
      {
        'date': '2025-09-10',
        'diagnosis': 'Fever & Vomiting',
        'prescription': 'Paracetamol 250mg (3 Days)',
      },
      {
        'date': '2025-08-18',
        'diagnosis': 'Allergy (Fleas)',
        'prescription': 'Antihistamine Spray',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Medical Record',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          // Navigate to AddDiagnosisScreen
        },
        label: const Text('Add Diagnosis'),
        icon: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _petInfoCard(),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Medical History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: medicalHistory.length,
                itemBuilder: (context, index) {
                  final record = medicalHistory[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.medical_services_outlined, color: Colors.green),
                      title: Text(record['diagnosis']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: ${record['date']}"),
                          Text("Prescription: ${record['prescription']}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _petInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage('assets/pet1.png'),
        ),
        title: const Text('Tommy', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Golden Retriever • Male • 2 Years'),
        trailing: IconButton(
          icon: const Icon(Icons.upload_file, color: Colors.green),
          onPressed: () {
            // Navigate to UploadMedicalFilesScreen
          },
        ),
      ),
    );
  }
}
