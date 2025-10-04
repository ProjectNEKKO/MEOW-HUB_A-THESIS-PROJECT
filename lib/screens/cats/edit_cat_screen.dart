import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';

class EditCatScreen extends StatefulWidget {
  final String catId;

  const EditCatScreen({super.key, required this.catId});

  @override
  State<EditCatScreen> createState() => _EditCatScreenState();
}

class _EditCatScreenState extends State<EditCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCat(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("cats")
        .doc(widget.catId)
        .get();

    final data = doc.data();
    if (data != null) {
      _nameCtrl.text = data["name"] ?? "";
      _breedCtrl.text = data["breed"] ?? "";
    }
  }

  Future<void> _saveCat(String userId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cats")
          .doc(widget.catId)
          .update({
        "name": _nameCtrl.text.trim(),
        "breed": _breedCtrl.text.trim().isEmpty ? "Unknown" : _breedCtrl.text.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context, true); // ✅ success
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update cat: $e")),
      );
    }
  }

  Future<void> _deleteCat(String userId) async {
    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("cats")
          .doc(widget.catId)
          .delete();

      if (mounted) {
        Navigator.pop(context, "deleted"); // ✅ signal deletion
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete cat: $e")),
      );
    }
  }

  void _confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Cat"),
        content: const Text("Are you sure you want to delete this cat? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _deleteCat(userId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }
    final userId = state.user.uid;

    return FutureBuilder(
      future: _loadCat(userId),
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(title: const Text("Edit Cat")),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cat name *',
                            hintText: 'e.g. Mochi',
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _breedCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Breed (optional)',
                            hintText: 'e.g. Persian',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : () => _saveCat(userId),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isDeleting ? null : () => _confirmDelete(userId),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                child: _isDeleting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.red,
                                          ),
                                        ),
                                      )
                                    : const Text("Delete Cat"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
