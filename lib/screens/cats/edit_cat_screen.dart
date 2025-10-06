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
  DateTime? _birthday;
  File? _photoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _breedCtrl = TextEditingController(text: widget.initialBreed ?? '');
    _ageCtrl = TextEditingController(
        text: widget.initialAge != null ? widget.initialAge.toString() : '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _updateCat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final catRef = FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("cats")
          .doc(widget.catId);

      await catRef.update({
        "name": _nameCtrl.text.trim(),
        "breed":
            _breedCtrl.text.trim().isEmpty ? "Unknown" : _breedCtrl.text.trim(),
        "age": int.tryParse(_ageCtrl.text.trim()),
        "gender": _gender ?? "Unknown",
        "birthday": _birthday,
        "photoUrl": widget.initialPhotoUrl, // TODO: upload new _photoFile if added
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Cat Profile"),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Card(
                margin: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Update Cat Info 🐾",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),

                          // 📸 Cat photo
                          GestureDetector(
                            onTap: _pickPhoto,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _photoFile != null
                                  ? FileImage(_photoFile!)
                                  : (widget.initialPhotoUrl != null &&
                                          widget.initialPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(widget.initialPhotoUrl!)
                                          as ImageProvider
                                      : null,
                              child: _photoFile == null &&
                                      (widget.initialPhotoUrl == null ||
                                          widget.initialPhotoUrl!.isEmpty)
                                  ? const Icon(Icons.camera_alt,
                                      size: 36, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🐱 Cat name
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: "Cat Name *",
                              prefixIcon: Icon(Icons.pets),
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? "Please enter a name"
                                    : null,
                          ),
                          const SizedBox(height: 12),

                          // 🧬 Breed
                          TextFormField(
                            controller: _breedCtrl,
                            decoration: const InputDecoration(
                              labelText: "Breed (optional)",
                              prefixIcon: Icon(Icons.category),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ⚧ Gender
                          DropdownButtonFormField<String>(
                            value: _gender,
                            items: const [
                              DropdownMenuItem(
                                  value: "Male", child: Text("Male")),
                              DropdownMenuItem(
                                  value: "Female", child: Text("Female")),
                              DropdownMenuItem(
                                  value: "Unknown", child: Text("Unknown")),
                            ],
                            onChanged: (val) => setState(() => _gender = val),
                            decoration: const InputDecoration(
                              labelText: "Gender",
                              prefixIcon: Icon(Icons.wc),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 🎂 Age
                          TextFormField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Age (in years)",
                              prefixIcon: Icon(Icons.cake),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 📅 Birthday
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _birthday == null
                                      ? "No birthday chosen"
                                      : "Birthday: ${_birthday!.toLocal().toString().split(' ')[0]}",
                                ),
                              ),
                              TextButton(
                                onPressed: _pickBirthday,
                                child: const Text("Pick Date"),
                              )
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 💾 Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text("Save Changes"),
                              onPressed: _isSaving ? null : _updateCat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ⏳ Loading overlay
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
}
