import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/widgets/cat/cat_form.dart'; // <-- import your CatForm

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Cat")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CatForm(
                isSaving: _isSaving,
                onSave: (name, breed, age, photoUrl) async {
                  setState(() => _isSaving = true);

                  try {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(userId)
                        .collection("cats")
                        .add({
                      "name": name,
                      "breed": breed.isEmpty ? "Unknown" : breed,
                      "age": age,
                      "photoUrl": photoUrl,
                      "createdAt": FieldValue.serverTimestamp(),
                      "updatedAt": FieldValue.serverTimestamp(),
                    });

                    if (mounted) Navigator.pop(context, true); // return success
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add cat: $e")),
                    );
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
