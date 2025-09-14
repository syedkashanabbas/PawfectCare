import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb

import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class AddEditPetProfileScreen extends StatefulWidget {
  final bool isEditing;
  const AddEditPetProfileScreen({super.key, this.isEditing = false});

  @override
  State<AddEditPetProfileScreen> createState() =>
      _AddEditPetProfileScreenState();
}

class _AddEditPetProfileScreenState extends State<AddEditPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customSpeciesController = TextEditingController();

  String gender = 'Male';
  String species = 'Dog';
  String imageUrl = '';
  File? _pickedImage;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("pets");

  Future<String?> _uploadToImgBB(dynamic imageFile) async {
    const String imgbbApiKey = "1ae657b6ec13bff848822f96f8e06c5b";
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$imgbbApiKey");

    try {
      if (kIsWeb) {
        // WEB: read as bytes → base64 encode
        final bytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(bytes);

        final response = await http.post(url, body: {"image": base64Image});

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return data["data"]["url"];
        }
      } else {
        // MOBILE: Multipart upload
        var request = http.MultipartRequest("POST", url);
        request.files.add(
          await http.MultipartFile.fromPath("image", (imageFile as File).path),
        );

        var response = await request.send();
        if (response.statusCode == 200) {
          var resBody = await response.stream.bytesToString();
          var data = json.decode(resBody);
          return data["data"]["url"];
        }
      }
    } catch (e) {
      debugPrint("Upload error: $e");
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
      await _uploadToImgBB(_pickedImage!);
    }
  }

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

      final petData = {
        "ownerId": userId,
        "name": nameController.text.trim(),
        "breed": breedController.text.trim(),
        "age": ageController.text.trim(),
        "gender": gender,
        "species": species == "Other"
            ? customSpeciesController.text.trim()
            : species,
        "imageUrl": imageUrl,
        "createdAt": DateTime.now().toIso8601String(),
      };

      await dbRef.push().set(petData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pet saved successfully!")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(
          widget.isEditing ? 'Edit Pet' : 'Add New Pet',
          style: const TextStyle(color: Colors.white),
        ),

        elevation: 0,
      ),
      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pet Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? const Icon(
                            Icons.add_a_photo,
                            size: 32,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Name',
                controller: nameController,
                icon: Icons.pets,
              ),
              _buildTextField(
                label: 'Breed',
                controller: breedController,
                icon: Icons.category,
              ),
              _buildTextField(
                label: 'Age',
                controller: ageController,
                keyboardType: TextInputType.number,
                icon: Icons.cake,
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Gender',
                value: gender,
                items: ['Male', 'Female'],
                onChanged: (val) => setState(() => gender = val),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Species',
                value: species,
                items: ['Dog', 'Cat', 'Bird', 'Other'],
                onChanged: (val) => setState(() => species = val),
              ),
              if (species == "Other") ...[
                const SizedBox(height: 12),
                _buildTextField(
                  label: "Enter custom species",
                  controller: customSpeciesController,
                  icon: Icons.edit,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? 'Update Pet' : 'Add Pet',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required field' : null,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.green[400])
              : null,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: (val) => onChanged(val!),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }
}
