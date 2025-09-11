import 'package:flutter/material.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BlogListScreen extends StatelessWidget {
  const BlogListScreen({super.key});

  final Color greenColor = const Color(0xFF4CAF50);

  final List<Map<String, String>> blogs = const [
    {
      "title": "Top 10 Pet Care Tips",
      "summary": "Learn essential tips to keep your pets healthy and happy every day.",
      "image": "https://via.placeholder.com/150x100.png?text=Pet+Tips"
    },
    {
      "title": "Healthy Foods for Dogs",
      "summary": "Discover the best food items to boost your dog's energy and immunity.",
      "image": "https://via.placeholder.com/150x100.png?text=Dog+Food"
    },
    {
      "title": "Grooming Guide for Cats",
      "summary": "Step-by-step grooming techniques every cat owner should know.",
      "image": "https://via.placeholder.com/150x100.png?text=Cat+Grooming"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text("Pet Care Blogs", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      drawer: const PetOwnerDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogs.length,
        itemBuilder: (context, index) {
          final blog = blogs[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      blog["image"]!,
                      width: 100,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Blog details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(blog["title"]!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(blog["summary"]!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to blog detail
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: greenColor,
                            ),
                            child: const Text("Read More"),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
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
    );
  }
}
