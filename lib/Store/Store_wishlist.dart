import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  Future<void> _addToCart(BuildContext context, Map<String, dynamic> item, String productId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(productId);

      final wishlistRef = FirebaseFirestore.instance
          .collection('wishlists')
          .doc(userId)
          .collection('items')
          .doc(productId);

      await cartRef.set({
        'productId': productId,
        'name': item['name'],
        'price': item['price'],
        'image': item['image'],
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await wishlistRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Moved to cart")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }


  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          title: const Text("My Wishlist", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: Text("Please log in to view your wishlist")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("My Wishlist", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('wishlists')
            .doc(userId)
            .collection('items')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items in wishlist"));
          }

          final wishlist = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wishlist.length,
            itemBuilder: (context, index) {
              final item = wishlist[index].data() as Map<String, dynamic>;
              final productId = wishlist[index].id;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item['name'] ?? ''),
                  subtitle: Text("\$${(item['price'] ?? 0).toStringAsFixed(2)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                        onPressed: () => _addToCart(context, item, productId),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('wishlists')
                              .doc(userId)
                              .collection('items')
                              .doc(productId)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Removed from wishlist")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
