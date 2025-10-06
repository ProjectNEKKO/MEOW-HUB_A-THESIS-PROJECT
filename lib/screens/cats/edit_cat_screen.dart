import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditCatScreen extends StatefulWidget {
  final String userId;
  final String catId;
  final String initialName;
  final String? initialBreed;
  final int? initialAge;
  final String? initialPhotoUrl;

  const EditCatScreen({
    super.key,
    required this.userId,
    required this.catId,
    required this.initialName,
    this.initialBreed,
    this.initialAge,
    this.initialPhotoUrl,
  });

  @override
  State<EditCatScreen> createState() => _EditCatScreenState();
}

class _EditCatScreenState extends State<EditCatScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _breedCtrl;
  late TextEditingController _ageCtrl;

  String? _gender;
  File? _photoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _breedCtrl = TextEditingController(text: widget.initialBreed ?? '');
    _ageCtrl = TextEditingController(
      text: widget.initialAge != null ? widget.initialAge.toString() : '',
    );
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photoFile = File(picked.path));
  }

  Future<void> _updateCat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("cats")
          .doc(widget.catId)
          .update({
        "name": _nameCtrl.text.trim(),
        "breed":
            _breedCtrl.text.trim().isEmpty ? "Unknown" : _breedCtrl.text.trim(),
        "age": int.tryParse(_ageCtrl.text.trim()),
        "gender": _gender ?? "Unknown",
        "photoUrl": widget.initialPhotoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update cat: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pastelPink = const Color(0xFFFFE4E1);
    final pastelBlue = const Color(0xFFB3E5FC);
    final pastelWhite = const Color(0xFFFFFAF9);

    return Scaffold(
      body: Stack(
        children: [
          // 🌈 Soft gradient background
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
                  shadowColor: pastelPink.withValues(alpha: .3),
                  color: Colors.white.withValues(alpha: .95),
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
                              "Edit Cat Profile 🐾",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade400,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🐱 Profile Image
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: CircleAvatar(
                                radius: 65,
                                backgroundColor: pastelPink.withValues(alpha: .4),
                                backgroundImage: _photoFile != null
                                    ? FileImage(_photoFile!)
                                    : (widget.initialPhotoUrl != null &&
                                            widget.initialPhotoUrl!.isNotEmpty)
                                        ? NetworkImage(widget.initialPhotoUrl!)
                                            as ImageProvider
                                        : null,
                                child: (_photoFile == null &&
                                        (widget.initialPhotoUrl == null ||
                                            widget.initialPhotoUrl!.isEmpty))
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
                                onPressed: _isSaving ? null : _updateCat,
                                icon: const Icon(Icons.save),
                                label: const Text("Save Changes"),
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
              color: Colors.black.withValues(alpha: .3),
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
          fillColor: Colors.pink.shade50.withValues(alpha: .4),
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
      initialValue: _gender,
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
        fillColor: Colors.pink.shade50.withValues(alpha: .4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
