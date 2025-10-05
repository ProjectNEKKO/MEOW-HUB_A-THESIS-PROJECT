import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pusa_app/widgets/cat/cat_form.dart';

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
  bool _isSaving = false;

  Future<void> _updateCat(String name, String breed, int? age, String? photoUrl) async {
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("cats")
          .doc(widget.catId)
          .update({
        "name": name,
        "breed": breed.isEmpty ? "Unknown" : breed,
        "age": age,
        "photoUrl": photoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context, true); // return success
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
      appBar: AppBar(title: const Text("Edit Cat")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CatForm(
                isSaving: _isSaving,
                initialName: widget.initialName,
                initialBreed: widget.initialBreed,
                initialAge: widget.initialAge,
                initialPhotoUrl: widget.initialPhotoUrl,
                onSave: _updateCat,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
