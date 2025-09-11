import 'package:flutter/material.dart';

class PetListingScreen extends StatelessWidget {
  const PetListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pets = [
      {
        'name': 'Tommy',
        'species': 'Dog',
        'breed': 'Golden Retriever',
        'age': '2 years',
        'image': 'assets/pet1.png',
      },
      {
        'name': 'Bella',
        'species': 'Cat',
        'breed': 'Persian',
        'age': '3 years',
        'image': 'assets/pet2.png',
      },
      {
        'name': 'Max',
        'species': 'Dog',
        'breed': 'Labrador',
        'age': '5 years',
        'image': 'assets/pet3.png',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('My Pets', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          Navigator.pushNamed(context, '/add_edit'); // Link to add/edit screen
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: pets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final pet = pets[index];
            return _petCard(pet);
          },
        ),
      ),
    );
  }

  Widget _petCard(Map<String, String> pet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(pet['image']!),
          ),
          const SizedBox(height: 8),
          Text(pet['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(pet['species']! + " • " + pet['breed']!, style: const TextStyle(fontSize: 12)),
          Text(pet['age']!, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          TextButton(
            onPressed: () {
              // You can add view or edit logic here
            },
            child: const Text("View Details"),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
