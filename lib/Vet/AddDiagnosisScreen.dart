import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Vet/VetDrawer.dart';

class AddDiagnosisScreen extends StatefulWidget {
  final String petId; // This should be passed from the previous screen

  const AddDiagnosisScreen({super.key, required this.petId});

  @override
  State<AddDiagnosisScreen> createState() => _AddDiagnosisScreenState();
}

class _AddDiagnosisScreenState extends State<AddDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _treatmentController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _vaccinationController = TextEditingController();
  DateTime? _nextVisitDate;

  @override
  void initState() {
    super.initState();
    // Make sure the selected pet ID is passed correctly
    print("Pet ID for this screen: ${widget.petId}"); // Debugging line
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text(
          'Add Diagnosis',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const VetDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _sectionLabel("Diagnosis"),
              TextFormField(
                controller: _diagnosisController,
                decoration: _inputDecoration("e.g., Ear infection, Cough"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Treatment Notes"),
              TextFormField(
                controller: _treatmentController,
                maxLines: 3,
                decoration: _inputDecoration("Describe the treatment..."),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Prescription"),
              TextFormField(
                controller: _prescriptionController,
                decoration: _inputDecoration("e.g., Antibiotic 5mg for 3 days"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Allergies"),
              TextFormField(
                controller: _allergyController,
                decoration: _inputDecoration("e.g., Skin Allergies"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Suggested Vaccinations"),
              TextFormField(
                controller: _vaccinationController,
                decoration: _inputDecoration("e.g., Rabies, Annual"),
              ),
              const SizedBox(height: 16),

              _sectionLabel("Next Visit Date"),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _nextVisitDate = pickedDate;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _nextVisitDate == null
                            ? "Select date"
                            : "${_nextVisitDate!.year}-${_nextVisitDate!.month}-${_nextVisitDate!.day}",
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Add a debugging print statement here
                    print("Form is valid! Submitting...");

                    // Submit logic to Firebase
                    _submitDiagnosis();
                  } else {
                    print("Form is invalid.");
                  }
                },
                child: const Text("Save Diagnosis", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
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

  // Submit the diagnosis, allergies, vaccinations to Firebase
  Future<void> _submitDiagnosis() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || widget.petId.isEmpty) return;

    final diagnosis = {
      'diagnosis': _diagnosisController.text,
      'treatment': _treatmentController.text,
      'prescription': _prescriptionController.text,
      'allergy': _allergyController.text,
      'vaccination': _vaccinationController.text,
      'nextVisitDate': _nextVisitDate?.toIso8601String(),
      'doctorId': userId,
      'date': DateTime.now().toIso8601String(),
    };

    try {
      // Insert the diagnosis into the Firebase healthRecords table
      final ref = FirebaseDatabase.instance.ref('healthRecords/${widget.petId}');
      await ref.push().set(diagnosis);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diagnosis added successfully")),
      );
      // Optionally reset the form or navigate back
      _formKey.currentState?.reset();
      setState(() {
        _nextVisitDate = null;  // Reset the date picker
      });
    } catch (error) {
      print("Error saving diagnosis: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add diagnosis")),
      );
    }
  }
}
