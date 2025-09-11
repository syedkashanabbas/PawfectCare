import 'package:flutter/material.dart';

class PetStoreScreen extends StatelessWidget {
  PetStoreScreen({super.key});

  final Color greenColor = const Color(0xFF4CAF50);

  // Dummy products for UI demo
  final List<Map<String, String>> products = [
    {
      "name": "Dog Food Premium",
      "price": "\$25",
      "image": "https://via.placeholder.com/120x120.png?text=Dog+Food"
    },
    {
      "name": "Cat Grooming Kit",
      "price": "\$40",
      "image": "https://via.placeholder.com/120x120.png?text=Cat+Kit"
    },
    {
      "name": "Pet Toys Pack",
      "price": "\$15",
      "image": "https://via.placeholder.com/120x120.png?text=Pet+Toys"
    },
    {
      "name": "Vitamin Supplements",
      "price": "\$30",
      "image": "https://via.placeholder.com/120x120.png?text=Vitamins"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text("Pet Store", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to Cart
            },
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final item = products[index];
            return _buildProductCard(item);
          },
        ),
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _buildProductCard(Map<String, String> item) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(item["image"]!, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item["price"]!, style: const TextStyle(color: Colors.green, fontSize: 14)),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Add to wishlist/cart
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text("Add to Cart"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2, // Explore tab for store
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
