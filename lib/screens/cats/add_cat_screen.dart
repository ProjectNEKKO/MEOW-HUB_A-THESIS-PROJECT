import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  String? _breed;
  int? _age;

  bool _loading = false;

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cats")
          .add({
        "name": _name,
        "breed": _breed,
        "age": _age,
        "photoUrl": null, // TODO: add photo upload later
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true); // return success
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add cat: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Cat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Enter cat's name" : null,
                onSaved: (value) => _name = value,
              ),
              const SizedBox(height: 12),

              // Breed
              TextFormField(
                decoration: const InputDecoration(labelText: "Breed"),
                onSaved: (value) => _breed = value,
              ),
              const SizedBox(height: 12),

              // Age
              TextFormField(
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _age = int.tryParse(value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: _loading ? null : _saveCat,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
