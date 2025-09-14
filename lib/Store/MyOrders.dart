import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawfectcare/Store/Store_Drawer.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (!authSnapshot.hasData) {
          debugPrint("⏳ No user logged in yet...");
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = authSnapshot.data!;
        debugPrint("🔥 Current logged-in UID: ${currentUser.uid}");

        final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

        return FutureBuilder<DocumentSnapshot>(
          future: userDocRef.get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              debugPrint("⏳ Waiting for user document...");
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final userData =
            userSnapshot.data!.data() as Map<String, dynamic>?;
            debugPrint("📄 User doc fetched from users collection: $userData");

            final userRole = userData?['role'] ?? 'user';
            debugPrint("👤 User role detected: $userRole");

            // 🚀 Fetch without orderBy to avoid timestamp null issue
            final ordersStream = FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: currentUser.uid)
                .snapshots();

            return Scaffold(
              appBar: AppBar(
                title: const Text("My Orders", style: TextStyle(color: Colors.white),),
                iconTheme: const IconThemeData(color: Colors.white),
                backgroundColor: Colors.green,
              ),
              drawer: StoreDrawer(role: userRole),
              body: StreamBuilder<QuerySnapshot>(
                stream: ordersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    debugPrint("⏳ Waiting for orders snapshot...");
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    debugPrint("⚠️ No orders found for UID: ${currentUser.uid}");
                    return const Center(child: Text("No orders found."));
                  }

                  // ✅ Client-side sort by timestamp if present
                  final orders = snapshot.data!.docs.toList();
                  orders.sort((a, b) {
                    final tsA = (a['timestamp'] ?? Timestamp(0, 0)) as Timestamp;
                    final tsB = (b['timestamp'] ?? Timestamp(0, 0)) as Timestamp;
                    return tsB.compareTo(tsA);
                  });

                  debugPrint("✅ Orders fetched: ${orders.length}");
                  for (var doc in orders) {
                    debugPrint("📦 Order doc: ${doc.id} => ${doc.data()}");
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final products = List<Map<String, dynamic>>.from(
                          order['products'] ?? []);
                      final date = (order['timestamp'] as Timestamp?)?.toDate();

                      return Card(
                        margin: const EdgeInsets.all(12),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Order ID: ${order.id}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("Date: ${date ?? 'Unknown'}"),
                              Text("Payment: ${order['paymentMethod']}"),
                              Text("Total: Rs. ${order['totalPrice']}"),
                              const Divider(),
                              const Text("Products:",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              for (var item in products)
                                ListTile(
                                  title: Text(item['name']),
                                  subtitle:
                                  Text("Qty: ${item['quantity']}"),
                                  trailing:
                                  Text("Rs. ${item['price']}"),
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
          },
        );
      },
    );
  }
}
