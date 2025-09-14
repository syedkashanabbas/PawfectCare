import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectcare/Store/Store_Drawer.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _role = "unknown";
        _loading = false;
      });
      return;
    }
    final doc =
    await FirebaseFirestore.instance.collection("users").doc(uid).get();
    setState(() {
      _role = doc.data()?["role"] ?? "unknown";
      _loading = false;
    });
  }

  Future<String> getUserName(String userId) async {
    try {
      final userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.exists ? (userDoc.data()?['name'] ?? 'Unknown') : 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role != "Super Admin") {
      return const Scaffold(
        body: Center(
          child: Text(
            "You are not authorized",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("All Orders", style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      drawer: StoreDrawer(role: _role ?? "unknown"),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final userId = order['userId'];
              final products =
              List<Map<String, dynamic>>.from(order['products']);

              return FutureBuilder<String>(
                future: getUserName(userId),
                builder: (context, userSnapshot) {
                  final userName = userSnapshot.data ?? 'Loading...';

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor: const Color(0xFFF0F0F0),
                      iconColor: Colors.green,
                      collapsedIconColor: Colors.grey,
                      title: Text(
                        userName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Total: \$${order['totalPrice']} | ${order['paymentMethod']} | ${order['city']}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      children: [
                        ...products.map(
                              (product) => ListTile(
                            title: Text(product['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text(
                                "Qty: ${product['quantity']} x \$${product['price']}"),
                            dense: true,
                          ),
                        ),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text("Name: ${order['name']}"),
                                      Text("Email: ${order['email']}"),
                                      Text("Phone: ${order['phone']}"),
                                      Text(
                                          "Address: ${order['address']}, ${order['city']}, ${order['zip']}"),
                                      Text("Total: \$${order['totalPrice']}"),
                                      Text("Payment: ${order['paymentMethod']}"),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
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
