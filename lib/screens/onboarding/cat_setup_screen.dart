import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // for photo picker
import 'dart:io';

import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/models/app_user.dart';
import 'package:pusa_app/screens/home/home_screen.dart';

class CatSetupScreen extends StatefulWidget {
  const CatSetupScreen({super.key});

  @override
  State<CatSetupScreen> createState() => _CatSetupScreenState();
}

class _CatSetupScreenState extends State<CatSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();

  String? _gender; // Male, Female, Unknown
  DateTime? _birthday;
  File? _photo;

  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365)), // default 1y ago
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  void _saveProfile(AppUser currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(currentUser.uid);

      final catsRef = userRef.collection("cats");
      final snapshot = await catsRef.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        final catDoc = snapshot.docs.first.reference;

        await catDoc.update({
          "name": _nameCtrl.text.trim(),
          "breed": _breedCtrl.text.trim().isEmpty ? "Unknown" : _breedCtrl.text.trim(),
          "gender": _gender ?? "Unknown",
          "birthday": _birthday,
          "photoUrl": null, // TODO: upload _photo to Firebase Storage
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      await userRef.update({"introCompleted": true});

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save cat: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthProfileIncomplete || state is AuthAuthenticated) {
          final user = (state is AuthProfileIncomplete)
              ? state.user
              : (state as AuthAuthenticated).user;

          return Scaffold(
            appBar: AppBar(title: const Text('Set up your cat')),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tell us about your cat',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 20),

                            // Profile Photo
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage:
                                    _photo != null ? FileImage(_photo!) : null,
                                child: _photo == null
                                    ? const Icon(Icons.camera_alt, size: 32)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Cat name
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Cat name *',
                                hintText: 'e.g. Mochi',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Enter a name'
                                      : null,
                            ),
                            const SizedBox(height: 12),

                            // Breed
                            TextFormField(
                              controller: _breedCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Breed (optional)',
                                hintText: 'e.g. Persian',
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Gender
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
                              decoration:
                                  const InputDecoration(labelText: "Gender"),
                            ),
                            const SizedBox(height: 12),

                            // Birthday
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
                                  child: const Text("Pick date"),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _saveProfile(user),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text('Save & Continue'),
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
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
