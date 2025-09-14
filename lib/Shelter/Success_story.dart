import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class SuccessStoriesScreen extends StatefulWidget {
  final String? storyId;         // null -> add mode, non-null -> edit mode
  final Map<String, dynamic>? oldData;

  const SuccessStoriesScreen({super.key, this.storyId, this.oldData});

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

  @override
  void initState() {
    super.initState();
    if (widget.storyId != null && widget.oldData != null) {
      // prefill data when editing
      _petNameController.text = widget.oldData!["petName"] ?? "";
      _adopterNameController.text = widget.oldData!["adopterName"] ?? "";
      _storyController.text = widget.oldData!["story"] ?? "";
    }
  }

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
    const apiKey = "7bac27b5a053536ee218ba8a64fc4d13"; // replace with your key
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

  Future<void> _saveOrUpdateStory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? petImageUrl = widget.oldData?["petImageUrl"];
    String? adopterImageUrl = widget.oldData?["adopterImageUrl"];

    if (_petImageFile != null || _petImageXFile != null) {
      petImageUrl = await _uploadToImgBB(_petImageFile, _petImageXFile);
    }
    if (_adopterImageFile != null || _adopterImageXFile != null) {
      adopterImageUrl = await _uploadToImgBB(_adopterImageFile, _adopterImageXFile);
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    final storyData = {
      "petName": _petNameController.text.trim(),
      "adopterName": _adopterNameController.text.trim(),
      "story": _storyController.text.trim(),
      "petImageUrl": petImageUrl ?? "",
      "adopterImageUrl": adopterImageUrl ?? "",
      "userId": userId,
      widget.storyId == null
          ? "createdAt"
          : "updatedAt": DateTime.now().toIso8601String(),
    };

    if (widget.storyId == null) {
      // add mode
      await dbRef.push().set(storyData);
    } else {
      // edit mode
      await dbRef.child(widget.storyId!).update(storyData);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success"),
          content: Text(widget.storyId == null
              ? "Story added successfully!"
              : "Story updated successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.storyId == null) {
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
                } else {
                  Navigator.pop(context); // close screen on update
                }
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
        title: Text(
          widget.storyId == null ? 'Add Success Story' : 'Edit Success Story',
          style: const TextStyle(color: Colors.white),
        ),
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
              _imagePicker(_petImageFile, _petImageXFile,
                      () => _pickImage(true), widget.oldData?["petImageUrl"]),

              const SizedBox(height: 16),
              _sectionLabel("Adopter Image"),
              _imagePicker(_adopterImageFile, _adopterImageXFile,
                      () => _pickImage(false), widget.oldData?["adopterImageUrl"]),

              const SizedBox(height: 20),
              _sectionLabel("Pet Name"),
              TextFormField(
                controller: _petNameController,
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
                decoration: _inputDecoration("e.g., Tommy"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Adopter Name"),
              TextFormField(
                controller: _adopterNameController,
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
                decoration: _inputDecoration("e.g., Ali Raza"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Success Story"),
              TextFormField(
                controller: _storyController,
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
                maxLines: 5,
                decoration: _inputDecoration(
                    "Share the heartwarming adoption story..."),
              ),
              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveOrUpdateStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  widget.storyId == null ? "Save Story" : "Update Story",
                  style: const TextStyle(
                      fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePicker(File? file, XFile? xfile, VoidCallback onTap,
      [String? oldUrl]) {
    ImageProvider? provider;
    if (file != null) {
      provider = FileImage(file);
    } else if (xfile != null) {
      provider = FileImage(File(xfile.path)); // <-- yahan dhyan do
    } else if (oldUrl != null && oldUrl.isNotEmpty) {
      provider = NetworkImage(oldUrl); // <-- ab yeh hi dikh jayega edit me
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: provider,
        child: provider == null
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
      contentPadding:
      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
