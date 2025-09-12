import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> wishlist = [
      {
        "title": "Wireless Headphones",
        "price": 89.99,
        "image": "https://via.placeholder.com/150",
      },
      {
        "title": "Eco Smartwatch",
        "price": 129.50,
        "image": "https://via.placeholder.com/150",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("My Wishlist", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: wishlist.isEmpty
          ? const Center(child: Text("No items in wishlist"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          final item = wishlist[index];
          final image = item["image"] as String;
          final title = item["title"] as String;
          final price = item["price"] as num;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(title),
              subtitle: Text("\$${price.toStringAsFixed(2)}"),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Removed from wishlist")),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
