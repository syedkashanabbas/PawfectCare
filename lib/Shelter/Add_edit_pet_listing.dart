import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditPetProfileScreen extends StatefulWidget {
  const AddEditPetProfileScreen({super.key});

  @override
  State<AddEditPetProfileScreen> createState() => _AddEditPetProfileScreenState();
}

class _AddEditPetProfileScreenState extends State<AddEditPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _species;
  String? _gender;
  File? _petImage;

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _genderOptions = ['Male', 'Female'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _petImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Add / Edit Pet', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                validator: (value) =>
                value == null || value.isEmpty ? "Required field" : null,
              ),
              const SizedBox(height: 16),
              _label("Species"),
              DropdownButtonFormField<String>(
                value: _species,
                items: _speciesOptions
                    .map((sp) => DropdownMenuItem(value: sp, child: Text(sp)))
                    .toList(),
                onChanged: (value) => setState(() => _species = value),
                decoration: _inputDecoration("Select species"),
              ),
              const SizedBox(height: 16),
              _label("Breed"),
              TextFormField(
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
                items: _genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
                decoration: _inputDecoration("Select gender"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pet profile saved (dummy logic).")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save", style: TextStyle(fontSize: 16)),
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
