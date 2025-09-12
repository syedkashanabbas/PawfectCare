import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

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
  File? _petImage;
  File? _adopterImage;

  Future<void> _pickImage(bool isPet) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isPet) {
          _petImage = File(picked.path);
        } else {
          _adopterImage = File(picked.path);
        }
      });
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
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionLabel("Pet Image"),
              _imagePicker(_petImage, () => _pickImage(true)),

              const SizedBox(height: 16),
              _sectionLabel("Adopter Image"),
              _imagePicker(_adopterImage, () => _pickImage(false)),

              const SizedBox(height: 20),
              _sectionLabel("Pet Name"),
              TextFormField(
                controller: _petNameController,
                decoration: _inputDecoration("e.g., Tommy"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Adopter Name"),
              TextFormField(
                controller: _adopterNameController,
                decoration: _inputDecoration("e.g., Ali Raza"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Success Story"),
              TextFormField(
                controller: _storyController,
                maxLines: 5,
                decoration: _inputDecoration("Share the heartwarming adoption story..."),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Success story saved (UI only).")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Save Story", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker(File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: image != null ? FileImage(image) : null,
        child: image == null ? const Icon(Icons.add_a_photo, color: Colors.white) : null,
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
