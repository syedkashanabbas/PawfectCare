import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

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
  File? _petImage;

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _genderOptions = ['Male', 'Female'];

  final _dbRef = FirebaseDatabase.instance.ref('adminpets');

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _petImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = const Uuid().v4();
      final storageRef = FirebaseStorage.instance.ref().child('pet_images/$fileName.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _saveToFirebase() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl;
    if (_petImage != null) {
      imageUrl = await _uploadImage(_petImage!);
    }

    final newPet = {
      'name': _nameController.text.trim(),
      'species': _species ?? '',
      'breed': _breedController.text.trim(),
      'age': _ageController.text.trim(),
      'gender': _gender ?? '',
      'imageUrl': imageUrl ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _dbRef.push().set(newPet);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pet profile saved!")),
    );

    _formKey.currentState?.reset();
    setState(() {
      _petImage = null;
      _species = null;
      _gender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Add / Edit Pet', style: TextStyle(color: Colors.white)),
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
                    backgroundImage: _petImage != null ? FileImage(_petImage!) : null,
                    child: _petImage == null
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

  Widget _label(String text) {
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
