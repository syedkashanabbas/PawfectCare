import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectcare/Store/CheckoutScreen.dart';
import 'package:pawfectcare/Store/Store_Drawer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<String> _getUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "unknown";

    final doc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final data = doc.data();
    return data?["role"] ?? "unknown";
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF4CAF50),
            title: const Text("My Cart", style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: StoreDrawer(role: role), // 👈 role pass
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('carts')
                .doc(userId)
                .collection('items')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Your cart is empty.'));
              }

              final items = snapshot.data!.docs;

              double totalPrice = 0;
              int totalItems = 0;

              for (var doc in items) {
                final data = doc.data() as Map<String, dynamic>;
                totalItems += (data['quantity'] as num).toInt();
                totalPrice += (data['price'] * data['quantity']);
              }

              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(
                        bottom: 130, top: 16, left: 16, right: 16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final data =
                      items[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: Image.network(data['image'],
                              width: 60, height: 60, fit: BoxFit.cover),
                          title: Text(data['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "\$${data['price']} x ${data['quantity']} = \$${(data['price'] * data['quantity']).toStringAsFixed(2)}"),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      int qty = data['quantity'];
                                      if (qty > 1) {
                                        FirebaseFirestore.instance
                                            .collection('carts')
                                            .doc(userId)
                                            .collection('items')
                                            .doc(data['productId'])
                                            .update({'quantity': qty - 1});
                                      }
                                    },
                                  ),
                                  Text('${data['quantity']}'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      int qty = data['quantity'];
                                      FirebaseFirestore.instance
                                          .collection('carts')
                                          .doc(userId)
                                          .collection('items')
                                          .doc(data['productId'])
                                          .update({'quantity': qty + 1});
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('carts')
                                  .doc(userId)
                                  .collection('items')
                                  .doc(data['productId'])
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Card(
                      elevation: 10,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Items:",
                                    style: TextStyle(fontSize: 16)),
                                Text("$totalItems",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Price:",
                                    style: TextStyle(fontSize: 16)),
                                Text("\$${totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const CheckoutScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("Proceed to Checkout",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}
