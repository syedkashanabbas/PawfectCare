import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  Future<String> getUserName(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.exists ? (userDoc.data()?['name'] ?? 'Unknown') : 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("All Orders"),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final userId = order['userId'];
              final products = List<Map<String, dynamic>>.from(order['products']);

              return FutureBuilder<String>(
                future: getUserName(userId),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data ?? 'Loading...';

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: const Color(0xFFF0F0F0),
                      iconColor: Colors.green,
                      collapsedIconColor: Colors.grey[600],
                      title: Text(
                        userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Total: \$${order['totalPrice']} | ${order['paymentMethod']} | ${order['city']}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      children: [
                        ...products.map((product) => ListTile(
                          title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text("Qty: ${product['quantity']} x \$${product['price']}"),
                          dense: true,
                        )),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Order Details"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Name: ${order['name']}"),
                                      Text("Email: ${order['email']}"),
                                      Text("Phone: ${order['phone']}"),
                                      Text("Address: ${order['address']}, ${order['city']}, ${order['zip']}"),
                                      Text("Total: \$${order['totalPrice']}"),
                                      Text("Payment: ${order['paymentMethod']}"),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text("View Details"),
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
