import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy product data with typed values
    final Map<String, dynamic> product = {
      "title": "Super Eco Printer",
      "price": 129.99,
      "desc":
      "An eco-friendly printer with high-yield toners and wireless support. Perfect for home and office use.",
      "image": "https://via.placeholder.com/300x200"
    };

    final String title = product["title"] as String;
    final double price = product["price"] as double;
    final String desc = product["desc"] as String;
    final String image = product["image"] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title:
        const Text("Product Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${price.toStringAsFixed(2)}",
            style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(desc),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Buy Now",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}
