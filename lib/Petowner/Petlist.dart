import 'package:flutter/material.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class PetProfileListScreen extends StatelessWidget {
  const PetProfileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: const Text('My Pets'),
        elevation: 0,
      ),
      drawer: const PetOwnerDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _petCard(
            name: 'Bello',
            age: '2 Years',
            breed: 'Golden Retriever',
            gender: 'Male',
            imageUrl: 'https://i.imgur.com/1.jpg',
          ),
          const SizedBox(height: 12),
          _petCard(
            name: 'Furry',
            age: '1.5 Years',
            breed: 'Persian Cat',
            gender: 'Female',
            imageUrl: 'https://i.imgur.com/3.jpg',
          ),
          const SizedBox(height: 12),
          _petCard(
            name: 'Rowdy',
            age: '3 Years',
            breed: 'German Shepherd',
            gender: 'Male',
            imageUrl: 'https://i.imgur.com/2.jpg',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to Add Pet screen
        },
      ),
    );
  }

  Widget _petCard({
    required String name,
    required String age,
    required String breed,
    required String gender,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(breed),
                Text(age),
                Text(gender),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.green),
            onPressed: () {
              // Edit pet profile logic
            },
          ),
        ],
      ),
    );
  }
}