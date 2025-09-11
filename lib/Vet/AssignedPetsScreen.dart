import 'package:flutter/material.dart';

class AssignedPetsScreen extends StatelessWidget {
  const AssignedPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> assignedPets = [
      {
        'name': 'Tommy',
        'breed': 'Golden Retriever',
        'age': '2 Years',
        'image': 'assets/pet1.png',
      },
      {
        'name': 'Bella',
        'breed': 'Persian Cat',
        'age': '3 Years',
        'image': 'assets/pet2.png',
      },
      {
        'name': 'Max',
        'breed': 'Labrador',
        'age': '5 Years',
        'image': 'assets/pet3.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Assigned Pets',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: assignedPets.length,
          itemBuilder: (context, index) {
            final pet = assignedPets[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(pet['image']!),
                  radius: 28,
                ),
                title: Text(
                  pet['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${pet['breed']} • ${pet['age']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    // View Record (no backend yet)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Record'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
