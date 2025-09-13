import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class AdminPetsListing extends StatelessWidget {
  const AdminPetsListing({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref("adminpets");

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Admin Pets", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No admin pets found"));
            }

            final petsMap = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final pets = petsMap.entries.map((e) {
              final pet = Map<String, dynamic>.from(e.value);
              pet["id"] = e.key;
              return pet;
            }).toList();

            return GridView.builder(
              itemCount: pets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _petCard(pet, dbRef, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _petCard(Map<String, dynamic> pet, DatabaseReference dbRef, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "edit") {
                  _showEditModal(context, pet, dbRef);
                } else if (value == "delete") {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Delete Pet"),
                      content: const Text("Are you sure you want to delete this pet?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await dbRef.child(pet["id"]).remove();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pet deleted")),
                    );
                  }
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: "edit", child: Text("Edit")),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundImage: pet['imageUrl'] != null && pet['imageUrl'] != ""
                ? NetworkImage(pet['imageUrl'])
                : null,
            child: (pet['imageUrl'] == null || pet['imageUrl'] == "")
                ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 8),
          Text(pet['name'] ?? "Pet",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("${pet['species']} • ${pet['breed']}",
              style: const TextStyle(fontSize: 12)),
          Text("Age: ${pet['age']}", style: const TextStyle(fontSize: 12)),
          Text("Gender: ${pet['gender']}", style: const TextStyle(fontSize: 12)),
          const Spacer(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showEditModal(BuildContext context, Map<String, dynamic> pet, DatabaseReference dbRef) {
    final nameCtrl = TextEditingController(text: pet['name']);
    final breedCtrl = TextEditingController(text: pet['breed']);
    final ageCtrl = TextEditingController(text: pet['age']);
    final genderCtrl = TextEditingController(text: pet['gender']);
    final speciesCtrl = TextEditingController(text: pet['species']);

    String? uploadedImageUrl = pet['imageUrl'];

    Future<void> pickAndUploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
  final bytes = await pickedFile.readAsBytes(); // works on web + mobile

  const apiKey = "7bac27b5a053536ee218ba8a64fc4d13";
  final uri = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

  final res = await http.post(uri, body: {
    "image": base64Encode(bytes),
  });

  final body = json.decode(res.body);
  if (res.statusCode == 200 && body['data'] != null) {
    uploadedImageUrl = body['data']['url'];
  }
}
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Pet"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await pickAndUploadImage();
                    (ctx as Element).markNeedsBuild();
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                        ? NetworkImage(uploadedImageUrl!)
                        : null,
                    child: uploadedImageUrl == null || uploadedImageUrl!.isEmpty
                        ? const Icon(Icons.add_a_photo, size: 30, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: "Species")),
                TextField(controller: breedCtrl, decoration: const InputDecoration(labelText: "Breed")),
                TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: "Age")),
                TextField(controller: genderCtrl, decoration: const InputDecoration(labelText: "Gender")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                await dbRef.child(pet['id']).update({
                  "name": nameCtrl.text,
                  "species": speciesCtrl.text,
                  "breed": breedCtrl.text,
                  "age": ageCtrl.text,
                  "gender": genderCtrl.text,
                  "imageUrl": uploadedImageUrl ?? "",
                  "timestamp": DateTime.now().millisecondsSinceEpoch,
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pet updated")),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
