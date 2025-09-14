import 'dart:convert';
import 'dart:io' show File; // mobile only
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';
import 'dart:typed_data';

class ShelterPetProfileScreen extends StatefulWidget {
  const ShelterPetProfileScreen({super.key});

  @override
  State<ShelterPetProfileScreen> createState() => _ShelterPetProfileScreenState();
}

class _ShelterPetProfileScreenState extends State<ShelterPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();

  String? _species;
  String? _gender;

  File? _petImageFile;  // mobile
  Uint8List? _petImageBytes; // web
  String? _petImageUrl; // final hosted imgbb url

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _genderOptions = ['Male', 'Female'];

  final _dbRef = FirebaseDatabase.instance.ref('adminpets');

  // TODO: Replace with your real imgbb API key
  static const String imgbbApiKey = "7bac27b5a053536ee218ba8a64fc4d13";

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _petImageBytes = bytes;
          _petImageFile = null;
        });
      } else {
        setState(() {
          _petImageFile = File(picked.path);
          _petImageBytes = null;
        });
      }
    }
  }

  Future<String?> _uploadToImgbb() async {
    try {
      final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");

      late List<int> bytes;
      if (_petImageFile != null) {
        bytes = await _petImageFile!.readAsBytes();
      } else if (_petImageBytes != null) {
        bytes = _petImageBytes!;
      } else {
        return null;
      }

      final base64Image = base64Encode(bytes);

      final response = await http.post(uri, body: {
        "image": base64Image,
        "name": const Uuid().v4(),
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["data"]["url"] as String?;
      } else {
        debugPrint("ImgBB upload failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("ImgBB error: $e");
      return null;
    }
  }

  Future<void> _saveToFirebase() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = _petImageUrl;
    if ((_petImageFile != null || _petImageBytes != null)) {
      imageUrl = await _uploadToImgbb();
    }

    final newPet = {
      'name': _nameController.text.trim(),
      'species': _species ?? '',
      'breed': _breedController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': _gender ?? '',
      'status':'available',
      'imageUrl': imageUrl ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _dbRef.push().set(newPet);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pet profile saved!")),
    );

    _formKey.currentState?.reset();
    setState(() {
      _petImageFile = null;
      _petImageBytes = null;
      _petImageUrl = null;
      _species = null;
      _gender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final preview = _petImageUrl != null
        ? NetworkImage(_petImageUrl!)
        : _petImageFile != null
        ? FileImage(_petImageFile!) as ImageProvider
        : _petImageBytes != null
        ? MemoryImage(_petImageBytes!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Add Pet', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: preview,
                    child: preview == null
                        ? const Icon(Icons.add_a_photo, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label("Pet Name"),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Enter pet's name"),
                validator: (value) => value == null || value.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 16),
              _label("Species"),
              DropdownButtonFormField<String>(
                value: _species,
                items: _speciesOptions.map((sp) => DropdownMenuItem(value: sp, child: Text(sp))).toList(),
                onChanged: (value) => setState(() => _species = value),
                decoration: _inputDecoration("Select species"),
              ),
              const SizedBox(height: 16),
              _label("Breed"),
              TextFormField(
                controller: _breedController,
                decoration: _inputDecoration("e.g., Golden Retriever"),
              ),
              const SizedBox(height: 16),
              _label("Age"),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("e.g., 2"),
              ),
              const SizedBox(height: 16),
              _label("Gender"),
              DropdownButtonFormField<String>(
                value: _gender,
                items: _genderOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (value) => setState(() => _gender = value),
                decoration: _inputDecoration("Select gender"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveToFirebase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold));

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
    );
  }
}
