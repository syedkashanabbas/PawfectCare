import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class SuccessStoriesScreen extends StatefulWidget {
  const SuccessStoriesScreen({super.key});

  @override
  State<SuccessStoriesScreen> createState() => _SuccessStoriesScreenState();
}

class _SuccessStoriesScreenState extends State<SuccessStoriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _adopterNameController = TextEditingController();
  final _storyController = TextEditingController();

  File? _petImageFile;
  File? _adopterImageFile;
  XFile? _petImageXFile;
  XFile? _adopterImageXFile;

  bool _isLoading = false;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("successStories");

  Future<void> _pickImage(bool isPet) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isPet) {
          if (kIsWeb) {
            _petImageXFile = picked;
          } else {
            _petImageFile = File(picked.path);
          }
        } else {
          if (kIsWeb) {
            _adopterImageXFile = picked;
          } else {
            _adopterImageFile = File(picked.path);
          }
        }
      });
    }
  }

  Future<String?> _uploadToImgBB(File? file, XFile? xfile) async {
    const apiKey = "YOUR_IMGBB_API_KEY"; // replace with your key
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      if (kIsWeb && xfile != null) {
        final bytes = await xfile.readAsBytes();
        String base64Image = base64Encode(bytes);
        final res = await http.post(url, body: {"image": base64Image});
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          return data["data"]["url"];
        }
      } else if (file != null) {
        var request = http.MultipartRequest("POST", url);
        request.files.add(await http.MultipartFile.fromPath("image", file.path));
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

    // upload images
    String? petImageUrl = await _uploadToImgBB(_petImageFile, _petImageXFile);
    String? adopterImageUrl = await _uploadToImgBB(_adopterImageFile, _adopterImageXFile);

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    final storyData = {
      "petName": _petNameController.text.trim(),
      "adopterName": _adopterNameController.text.trim(),
      "story": _storyController.text.trim(),
      "petImageUrl": petImageUrl ?? "",
      "adopterImageUrl": adopterImageUrl ?? "",
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
          content: const Text("Success story saved!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                _formKey.currentState!.reset();
                _petNameController.clear();
                _adopterNameController.clear();
                _storyController.clear();
                setState(() {
                  _petImageFile = null;
                  _adopterImageFile = null;
                  _petImageXFile = null;
                  _adopterImageXFile = null;
                });
              },
              child: const Text("OK"),
            )
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
        title: const Text('Add Success Story', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionLabel("Pet Image"),
              _imagePicker(_petImageFile, _petImageXFile, () => _pickImage(true)),

              const SizedBox(height: 16),
              _sectionLabel("Adopter Image"),
              _imagePicker(_adopterImageFile, _adopterImageXFile, () => _pickImage(false)),

              const SizedBox(height: 20),
              _sectionLabel("Pet Name"),
              TextFormField(
                controller: _petNameController,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                decoration: _inputDecoration("e.g., Tommy"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Adopter Name"),
              TextFormField(
                controller: _adopterNameController,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                decoration: _inputDecoration("e.g., Ali Raza"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Success Story"),
              TextFormField(
                controller: _storyController,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
                maxLines: 5,
                decoration: _inputDecoration("Share the heartwarming adoption story..."),
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

  Widget _imagePicker(File? file, XFile? xfile, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: file != null
            ? FileImage(file)
            : (xfile != null ? NetworkImage(xfile.path) as ImageProvider : null),
        child: (file == null && xfile == null)
            ? const Icon(Icons.add_a_photo, color: Colors.white)
            : null,
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
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
    );
  }
}
