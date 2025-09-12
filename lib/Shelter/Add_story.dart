import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  XFile? _imageXFile;
  bool _isLoading = false;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("stories");

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        setState(() => _imageXFile = picked);
      } else {
        setState(() => _imageFile = File(picked.path));
      }
    }
  }

  Future<String?> _uploadToImgBB() async {
    const apiKey = "7bac27b5a053536ee218ba8a64fc4d13"; // replace with your key
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      if (kIsWeb && _imageXFile != null) {
        final bytes = await _imageXFile!.readAsBytes();
        String base64Image = base64Encode(bytes);
        final res = await http.post(url, body: {"image": base64Image});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data["data"]["url"];
        }
      } else if (_imageFile != null) {
        var request = http.MultipartRequest("POST", url);
        request.files.add(await http.MultipartFile.fromPath("image", _imageFile!.path));
        var response = await request.send();
        if (response.statusCode == 200) {
          var resBody = await response.stream.bytesToString();
          var data = jsonDecode(resBody);
          return data["data"]["url"];
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }
    return null;
  }

 Future<void> _saveStory() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  String? imageUrl = "";
  if (_imageFile != null || _imageXFile != null) {
    imageUrl = await _uploadToImgBB();
  }

  final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

  final storyData = {
    "title": _titleController.text.trim(),
    "description": _descriptionController.text.trim(),
    "imageUrl": imageUrl ?? "",
    "createdAt": DateTime.now().toIso8601String(),
    "userId": userId,
  };

  await dbRef.push().set(storyData);

  setState(() => _isLoading = false);

  if (mounted) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Story saved successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              _formKey.currentState!.reset();
              _titleController.clear();
              _descriptionController.clear();
              setState(() {
                _imageFile = null;
                _imageXFile = null;
              });
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Add New Story', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionLabel("Cover Image"),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                    image: _imageFile != null
                        ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : (_imageXFile != null
                            ? DecorationImage(image: NetworkImage(_imageXFile!.path), fit: BoxFit.cover)
                            : null),
                  ),
                  child: (_imageFile == null && _imageXFile == null)
                      ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: Colors.white))
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _sectionLabel("Story Title"),
              TextFormField(
                controller: _titleController,
                validator: (val) => val == null || val.isEmpty ? "Title required" : null,
                decoration: _inputDecoration("Enter story title"),
              ),
              const SizedBox(height: 16),
              _sectionLabel("Story Description"),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                validator: (val) => val == null || val.isEmpty ? "Description required" : null,
                decoration: _inputDecoration("Write the full story here..."),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Save Story", style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
