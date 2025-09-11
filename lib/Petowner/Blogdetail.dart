import 'package:flutter/material.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BlogDetailScreen extends StatelessWidget {
  final String title;
  final String image;
  final String description;

  const BlogDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Color greenColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        leading: const BackButton(color: Colors.white),
        title: const Text("Blog Detail", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white),
            onPressed: () {
              // TODO: Bookmark action
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Share action
            },
          ),
        ],
      ),
      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            // Description (long text)
            Text(
              description,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Discover tab
        selectedItemColor: greenColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Manage"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
