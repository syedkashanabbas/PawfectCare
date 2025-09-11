import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_database/firebase_database.dart';

class AddEditPetProfileScreen extends StatefulWidget {
  final bool isEditing;
  const AddEditPetProfileScreen({super.key, this.isEditing = false});

  @override
  State<AddEditPetProfileScreen> createState() => _AddEditPetProfileScreenState();
}

class _AddEditPetProfileScreenState extends State<AddEditPetProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customSpeciesController = TextEditingController();

  String gender = 'Male';
  String species = 'Dog';
  String imageUrl = '';
  late AnimationController _animController;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("pets");

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    customSpeciesController.dispose();
    super.dispose();
  }

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      final petData = {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pet saved successfully!")),
      );

      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        title: Text(widget.isEditing ? 'Edit Pet' : 'Add New Pet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: FadeTransition(
            opacity: _animController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pet Photo',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () {
                   
                    },
                    child: Hero(
                      tag: 'pet_photo',
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: imageUrl.isNotEmpty
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: CircleAvatar(
                                  key: const ValueKey('img'),
                                  radius: 48,
                                  backgroundImage: NetworkImage(imageUrl),
                                ),
                              )
                            : Container(
                                key: const ValueKey('lottie'),
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.15),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Lottie.asset(
                                  'assets/lottie/pet.json',
                                  repeat: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                    label: 'Name',
                    controller: nameController,
                    icon: Icons.pets),
                _buildTextField(
                    label: 'Breed',
                    controller: breedController,
                    icon: Icons.category),
                _buildTextField(
                    label: 'Age',
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    icon: Icons.cake),
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _savePet,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            widget.isEditing ? 'Update Pet' : 'Add Pet',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.green.withOpacity(0.08),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) =>
              value == null || value.isEmpty ? 'Required field' : null,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Colors.green[400]) : null,
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            fillColor: Colors.white,
            filled: true,
          ),
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
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          shadowColor: Colors.green.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              onChanged: (val) => onChanged(val!),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
