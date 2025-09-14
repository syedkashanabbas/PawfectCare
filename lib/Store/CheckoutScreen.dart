import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectcare/Store/Store_Drawer.dart';
import 'package:pawfectcare/Store/ThankYouScreen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  String name = '';
  String email = '';
  String phone = '';
  String address = '';
  String city = '';
  String zip = '';

  bool isLoading = true;
  String userRole = "unknown";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final doc =
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final data = doc.data() ?? {};

    setState(() {
      name = data['name'] ?? '';
      email = data['email'] ?? '';
      userRole = data['role'] ?? 'unknown';
      isLoading = false;
    });
  }

  Future<void> placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final cartItems = await FirebaseFirestore.instance
        .collection('carts')
        .doc(user!.uid)
        .collection('items')
        .get();

    double totalPrice = 0;
    List<Map<String, dynamic>> products = [];

    for (var doc in cartItems.docs) {
      final data = doc.data();
      totalPrice += (data['price'] * data['quantity']);
      products.add({
        'name': data['name'],
        'price': data['price'],
        'quantity': data['quantity'],
      });
    }

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': user!.uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'zip': zip,
      'paymentMethod': 'COD',
      'timestamp': FieldValue.serverTimestamp(),
      'products': products,
      'totalPrice': totalPrice,
    });

    await FirebaseFirestore.instance
        .collection('carts')
        .doc(user!.uid)
        .collection('items')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ThankYouScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order placed successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: StoreDrawer(role: userRole), // 👈 role-based drawer
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Customer Details",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: "Name"),
                onSaved: (val) => name = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: "Email"),
                onSaved: (val) => email = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                onSaved: (val) => phone = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Address"),
                onSaved: (val) => address = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "City"),
                onSaved: (val) => city = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "ZIP / Postal Code"),
                keyboardType: TextInputType.number,
                onSaved: (val) => zip = val ?? '',
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Payment Method",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 15),
              Card(
                color: Colors.green.shade100,
                child: const ListTile(
                  leading: Icon(Icons.money, color: Colors.green),
                  title: Text("Cash on Delivery"),
                  subtitle: Text("Pay when you receive the product"),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Order Summary",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),

              // 🔥 Live Cart Summary
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('carts')
                    .doc(user!.uid)
                    .collection('items')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("Loading...");
                  final items = snapshot.data!.docs;
                  if (items.isEmpty) return const Text("Cart is empty.");

                  double total = 0;
                  for (var doc in items) {
                    final d = doc.data() as Map<String, dynamic>;
                    total += d['price'] * d['quantity'];
                  }

                  return Card(
                    color: Colors.grey.shade100,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...items.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                  "${d['name']} x ${d['quantity']} = \$${(d['price'] * d['quantity']).toStringAsFixed(2)}"),
                            );
                          }),
                          const Divider(),
                          Text("Total: \$${total.toStringAsFixed(2)}",
                              style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              ElevatedButton(
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text("Place Order",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
