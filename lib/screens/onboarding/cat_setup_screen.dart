import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
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

  String? _gender;
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
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF84A7D3), // light blue
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A4A4A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthday = picked);
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
          "breed": _breedCtrl.text.trim().isEmpty
              ? "Unknown"
              : _breedCtrl.text.trim(),
          "gender": _gender ?? "Unknown",
          "birthday": _birthday,
          "photoUrl": null,
          "updatedAt": FieldValue.serverTimestamp(),
        });
      }

      await userRef.update({
        "displayName": "${_nameCtrl.text.trim()}'s Parent",
        "introCompleted": true
      });

      if (mounted) {
        context.read<AuthBloc>().add(UpdateProfileRequested(currentUser));
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to save cat: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const lightPink = Color(0xFFFFD9E8);
    const softBlue = Color(0xFF84A7D3);
    const offWhite = Color(0xFFFDF7F7);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is AuthProfileIncomplete || state is AuthAuthenticated) {
          final user = (state is AuthProfileIncomplete)
              ? state.user
              : (state as AuthAuthenticated).user;

          return Scaffold(
            backgroundColor: offWhite,
            appBar: AppBar(
              title: const Text('Set Up Your Cat 🐾'),
              centerTitle: true,
              backgroundColor: softBlue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Card(
                  margin: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: Colors.white,
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              'Tell us about your furry friend 🐱',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: softBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // 🐾 Photo
                            GestureDetector(
                              onTap: _pickPhoto,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: lightPink.withValues(alpha: .5),
                                backgroundImage:
                                    _photo != null ? FileImage(_photo!) : null,
                                child: _photo == null
                                    ? const Icon(Icons.camera_alt,
                                        size: 36, color: Colors.grey)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🐱 Name
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: "Cat name *",
                                prefixIcon: const Icon(Icons.pets),
                                filled: true,
                                fillColor: lightPink.withValues(alpha: .2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Please enter a name"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // 🧬 Breed
                            TextFormField(
                              controller: _breedCtrl,
                              decoration: InputDecoration(
                                labelText: "Breed (optional)",
                                prefixIcon: const Icon(Icons.category),
                                filled: true,
                                fillColor: lightPink.withValues(alpha: .2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ⚧ Gender
                            DropdownButtonFormField<String>(
                              initialValue: _gender,
                              items: const [
                                DropdownMenuItem(
                                    value: "Male", child: Text("Male")),
                                DropdownMenuItem(
                                    value: "Female", child: Text("Female")),
                                DropdownMenuItem(
                                    value: "Unknown", child: Text("Unknown")),
                              ],
                              onChanged: (val) => setState(() => _gender = val),
                              decoration: InputDecoration(
                                labelText: "Gender",
                                prefixIcon: const Icon(Icons.wc),
                                filled: true,
                                fillColor: lightPink.withValues(alpha: .2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🎂 Birthday
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _birthday == null
                                        ? "No birthday chosen"
                                        : "Birthday: ${_birthday!.toLocal().toString().split(' ')[0]}",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _pickBirthday,
                                  style: TextButton.styleFrom(
                                    foregroundColor: softBlue,
                                  ),
                                  child: const Text("Pick date"),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // 💾 Save Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check_circle_outline),
                                label: _isSaving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text("Save & Continue"),
                                onPressed: _isSaving
                                    ? null
                                    : () => _saveProfile(user),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: softBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
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
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
