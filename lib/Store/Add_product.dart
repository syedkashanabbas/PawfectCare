import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Store/Store_Drawer.dart';

class ShelterUploadProductScreen extends StatefulWidget {
  const ShelterUploadProductScreen({super.key});

  @override
  State<ShelterUploadProductScreen> createState() =>
      _ShelterUploadProductScreenState();
}

class _ShelterUploadProductScreenState
    extends State<ShelterUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  String _category = "grooming";
  Uint8List? _webImageBytes;
  String? _uploadedImageUrl;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();
  final database = FirebaseDatabase.instance.ref().child("products");

  Future<void> _pickImage() async {
    final picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _webImageBytes = bytes);
    }
  }

  Future<String?> _uploadToImgBB(Uint8List bytes) async {
    final url = Uri.parse(
        "https://api.imgbb.com/1/upload?key=7bac27b5a053536ee218ba8a64fc4d13");
    final base64Image = base64Encode(bytes);
    final response = await http.post(url, body: {
      "image": base64Image,
      "name": "product_${DateTime.now().millisecondsSinceEpoch}"
    });

    final data = json.decode(response.body);
    if (data["success"]) return data["data"]["url"];
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _webImageBytes == null) return;
    setState(() => _loading = true);

    final imageUrl = await _uploadToImgBB(_webImageBytes!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed")));
      setState(() => _loading = false);
      return;
    }

    await database.push().set({
      "name": _nameController.text.trim(),
      "price": double.parse(_priceController.text.trim()),
      "description": _descController.text.trim(),
      "category": _category,
      "image": imageUrl,
      "timestamp": DateTime.now().toIso8601String()
    });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product uploaded successfully")));
    _formKey.currentState!.reset();
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _descController.clear();
      _webImageBytes = null;
      _uploadedImageUrl = imageUrl;
      _category = "grooming";
      _loading = false;
    });
  }

  /// 🔥 Firestore se current user role fetch karna
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
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!;

        if (role != "Super Admin") {
          // ❌ Agar Super Admin nahi hai
          return Scaffold(
            appBar: AppBar(
              title: const Text("Access Denied",
                  style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF4CAF50),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(
              child: Text(
                "You don’t have permission to upload products.",
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        }

        // ✅ Agar role Super Admin hai, normal form dikhao
        return Scaffold(
          backgroundColor: const Color(0xFFEFFAF0),
          appBar: AppBar(
            title: const Text("Upload Product",
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF4CAF50),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          drawer: StoreDrawer(role: role), // 👈 ab role pass ho raha hai
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: _webImageBytes == null
                          ? const Center(child: Text("Tap to select image"))
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_webImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                    const InputDecoration(labelText: "Product Name"),
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descController,
                    decoration:
                    const InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    validator: (val) => val!.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: _category,
                    decoration:
                    const InputDecoration(labelText: "Category"),
                    items: const [
                      DropdownMenuItem(
                          value: "grooming", child: Text("Grooming")),
                      DropdownMenuItem(value: "food", child: Text("Food")),
                      DropdownMenuItem(value: "toys", child: Text("Toys")),
                      DropdownMenuItem(value: "health", child: Text("Health")),
                    ],
                    onChanged: (val) =>
                        setState(() => _category = val as String),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _loading
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.upload, color: Colors.white,),
                    label: Text(_loading ? "Uploading..." : "Upload",
                        style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
