import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _gender;
  File? _photoFile;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photoFile = File(picked.path));
  }

  Future<void> _saveCat(String userId) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cats")
          .add({
        "name": _nameCtrl.text.trim(),
        "breed":
            _breedCtrl.text.trim().isEmpty ? "Unknown" : _breedCtrl.text.trim(),
        "age": int.tryParse(_ageCtrl.text.trim()) ?? 0,
        "gender": _gender ?? "Unknown",
        "photoUrl": "", // add later when photo upload feature is implemented
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to add cat: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    final pastelPink = const Color(0xFFFFE4E1);
    final pastelBlue = const Color(0xFFB3E5FC);
    final pastelWhite = const Color(0xFFFFFAF9);

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [pastelPink, pastelWhite, pastelBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 10,
                  shadowColor: pastelPink.withOpacity(0.3),
                  color: Colors.white.withOpacity(0.95),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              "Add a New Cat 🐾",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🐱 Photo picker
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: pastelPink.withOpacity(0.4),
                                backgroundImage: _photoFile != null
                                    ? FileImage(_photoFile!)
                                    : null,
                                child: _photoFile == null
                                    ? const Icon(Icons.camera_alt,
                                        size: 36, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // 📝 Form Fields
                            _buildTextField(_nameCtrl, "Cat Name *",
                                icon: Icons.pets, required: true),
                            _buildTextField(_breedCtrl, "Breed (optional)",
                                icon: Icons.category),

                            const SizedBox(height: 12),
                            _buildDropdown(),

                            const SizedBox(height: 12),
                            _buildTextField(_ageCtrl, "Age (years)",
                                icon: Icons.cake,
                                inputType: TextInputType.number),

                            const SizedBox(height: 25),

                            // 💾 Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : () => _saveCat(userId),
                                icon: const Icon(Icons.add),
                                label: const Text("Add Cat"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.pinkAccent.shade100,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {IconData? icon, bool required = false, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.pinkAccent.shade200)
              : null,
          filled: true,
          fillColor: Colors.pink.shade50.withOpacity(0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (val) {
          if (required && (val == null || val.trim().isEmpty)) {
            return "This field is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
        DropdownMenuItem(value: "Unknown", child: Text("Unknown")),
      ],
      onChanged: (val) => setState(() => _gender = val),
      decoration: InputDecoration(
        labelText: "Gender",
        prefixIcon: Icon(Icons.wc, color: Colors.pinkAccent.shade200),
        filled: true,
        fillColor: Colors.pink.shade50.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
