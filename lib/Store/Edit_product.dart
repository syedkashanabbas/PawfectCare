import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AdminProductScreen extends StatefulWidget {
  const AdminProductScreen({super.key});

  @override
  State<AdminProductScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductScreen> {
  List<Map<String, dynamic>> _products = [];
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Example: current user role fetch
    // TODO: replace USER_ID with actual auth uid
    FirebaseDatabase.instance.ref().child("users/USER_ID/role").get().then((snap) {
      if (snap.exists) {
        setState(() {
          _role = snap.value.toString();
          _loading = false;
        });
      } else {
        setState(() {
          _role = null;
          _loading = false;
        });
      }
    });

    // Products listener
    FirebaseDatabase.instance.ref().child("products").onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final list = data.entries.map((e) {
          final val = Map<String, dynamic>.from(e.value);
          val['id'] = e.key;
          return val;
        }).toList();
        setState(() => _products = list);
      }
    });
  }

  void _deleteProduct(String id) async {
    await FirebaseDatabase.instance.ref().child("products").child(id).remove();
  }

  void _editProduct(Map<String, dynamic> product) {
    final nameCtrl = TextEditingController(text: product['name']);
    final descCtrl = TextEditingController(text: product['description']);
    final priceCtrl = TextEditingController(text: product['price']?.toString());
    String category = product['category'] ?? "grooming";
    Uint8List? _webImageBytes;
    String? _uploadedImageUrl = product['image'];

    Future<void> _pickImage() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        _webImageBytes = bytes;
      }
    }

    Future<String?> _uploadToImgBB(Uint8List bytes) async {
      final url = Uri.parse("https://api.imgbb.com/1/upload?key=7bac27b5a053536ee218ba8a64fc4d13");
      final base64Image = base64Encode(bytes);
      final response = await http.post(url, body: {
        "image": base64Image,
        "name": "product_${DateTime.now().millisecondsSinceEpoch}"
      });
      final data = json.decode(response.body);
      if (data["success"]) return data["data"]["url"];
      return null;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _pickImage();
                    if (_webImageBytes != null) {
                      final url = await _uploadToImgBB(_webImageBytes!);
                      if (url != null) {
                        setState(() => _uploadedImageUrl = url);
                      }
                    }
                  },
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _uploadedImageUrl == null
                        ? const Center(child: Text("Tap to select image"))
                        : Image.network(_uploadedImageUrl!, fit: BoxFit.cover),
                  ),
                ),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                DropdownButtonFormField(
                  value: category,
                  decoration: const InputDecoration(labelText: "Category"),
                  items: const [
                    DropdownMenuItem(value: "grooming", child: Text("Grooming")),
                    DropdownMenuItem(value: "food", child: Text("Food")),
                    DropdownMenuItem(value: "toys", child: Text("Toys")),
                    DropdownMenuItem(value: "health", child: Text("Health")),
                  ],
                  onChanged: (val) => setState(() => category = val as String),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final updated = {
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'price': int.tryParse(priceCtrl.text.trim()) ?? 0,
                  'image': _uploadedImageUrl ?? '',
                  'category': category,
                  'timestamp': DateTime.now().toIso8601String(),
                };
                await FirebaseDatabase.instance.ref().child("products").child(product['id']).update(updated);
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_role != "shelter") {
      return const Scaffold(
        body: Center(
          child: Text(
            "You are not admin",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Admin: Manage Products")),
      body: _products.isEmpty
          ? const Center(child: Text("No products found"))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (_, i) {
          final p = _products[i];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      p['image'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rs. ${p['price'] ?? 0}", style: const TextStyle(color: Colors.green)),
                      Text("Category: ${p['category'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(onPressed: () => _editProduct(p), icon: const Icon(Icons.edit, color: Colors.blue)),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Confirm Delete"),
                                  content: Text("Delete '${p['name']}' permanently?"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteProduct(p['id']);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text("Delete"),
                                    )
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
