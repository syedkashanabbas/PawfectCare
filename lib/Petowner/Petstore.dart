import 'package:flutter/material.dart';

class PetStoreScreen extends StatelessWidget {
  const PetStoreScreen({super.key});

  final Color greenColor = const Color(0xFF4CAF50);

  final List<Map<String, String>> products = const [
    {
      "name": "Josera Adult Food",
      "price": "\$20",
      "image": "https://via.placeholder.com/120x120.png?text=Josera"
    },
    {
      "name": "Nutripet Chicken 5kg",
      "price": "\$35",
      "image": "https://via.placeholder.com/120x120.png?text=Nutripet"
    },
    {
      "name": "Royal Canin Puppy",
      "price": "\$28",
      "image": "https://via.placeholder.com/120x120.png?text=Royal+Canin"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: greenColor,
          title: const Text("Pet Store", style: TextStyle(color: Colors.white)),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.location_on), text: "Retail Stores"),
              Tab(icon: Icon(Icons.shopping_bag), text: "Shop"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMapPlaceholder(),
            _buildShopView(),
          ],
        ),
        bottomNavigationBar: _bottomNavBar(),
      ),
    );
  }

  // Placeholder Map UI (no backend logic)
  Widget _buildMapPlaceholder() {
    return const Center(
      child: Icon(Icons.map, size: 120, color: Colors.grey),
    );
  }

  // Shop view UI
  Widget _buildShopView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recommended Food",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = products[index];
                return _buildProductCard(item, isHorizontal: true);
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text("Top Selling",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(
            children: products.map((item) => _buildProductCard(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> item, {bool isHorizontal = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Container(
        width: isHorizontal ? 150 : double.infinity,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item["image"]!,
                  height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(item["name"]!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(item["price"]!, style: TextStyle(color: greenColor)),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () {
                // UI only: no backend
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text("Add to Cart"),
            )
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: greenColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "Explore"),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), label: "Manage"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
