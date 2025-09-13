import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late DatabaseReference _productRef;
  Map<String, dynamic>? productData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _productRef = FirebaseDatabase.instance.ref().child('products/${widget.productId}');
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    try {
      final snapshot = await _productRef.get();
      if (snapshot.exists) {
        setState(() {
          productData = Map<String, dynamic>.from(snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product not found')));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Product Details", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productData == null
          ? const Center(child: Text("No data found."))
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(productData!["image"] ?? ""),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            productData!["name"] ?? "",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "\$${(productData!["price"] ?? 0).toStringAsFixed(2)}",
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
          Text(productData!["description"] ?? ""),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in')));
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('carts')
                    .doc(userId)
                    .collection('items')
                    .doc(widget.productId)
                    .set({
                  'productId': widget.productId,
                  'name': productData!['name'],
                  'price': productData!['price'],
                  'image': productData!['image'],
                  'quantity': 1,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to cart')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Add To Cart", style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}
