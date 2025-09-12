import 'dart:typed_data';
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditBlogScreen extends StatefulWidget {
  const AddEditBlogScreen({super.key});

  @override
  State<AddEditBlogScreen> createState() => _AddEditBlogScreenState();
}

class _AddEditBlogScreenState extends State<AddEditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Uint8List? _pickedImageWeb;
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      if (kIsWeb) {
        final data = await file.readAsBytes();
        setState(() => _pickedImageWeb = data);
      } else {
        setState(() => _pickedImage = file);
      }
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pretend blog saved.')),
    );

    _formKey.currentState?.reset();
    setState(() {
      _pickedImageWeb = null;
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Add / Edit Blog', style: TextStyle(color: Colors.white)),
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
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                      image: _hasImage()
                          ? DecorationImage(
                          image: _getImageProvider(), fit: BoxFit.cover)
                          : null,
                    ),
                    child: !_hasImage()
                        ? const Icon(Icons.add_photo_alternate, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label("Blog Title"),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Enter title"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              _label("Blog Description"),
              TextFormField(
                controller: _descController,
                maxLines: 6,
                decoration: _inputDecoration("Write something..."),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );
  }

  bool _hasImage() {
    return kIsWeb ? _pickedImageWeb != null : _pickedImage != null;
  }

  ImageProvider _getImageProvider() {
    if (kIsWeb) {
      return MemoryImage(_pickedImageWeb!);
    } else {
      return FileImage(File(_pickedImage!.path));
    }
  }
}
