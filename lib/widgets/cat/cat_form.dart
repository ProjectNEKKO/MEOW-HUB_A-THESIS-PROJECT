import 'package:flutter/material.dart';

class CatForm extends StatefulWidget {
  final String? initialName;
  final String? initialBreed;
  final int? initialAge;
  final String? initialPhotoUrl;
  final void Function(String name, String breed, int? age, String? photoUrl) onSave;
  final bool isSaving;

  const CatForm({
    super.key,
    this.initialName,
    this.initialBreed,
    this.initialAge,
    this.initialPhotoUrl,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  State<CatForm> createState() => _CatFormState();
}

class _CatFormState extends State<CatForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _ageCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? "");
    _breedCtrl = TextEditingController(text: widget.initialBreed ?? "");
    _ageCtrl = TextEditingController(
        text: widget.initialAge != null ? widget.initialAge.toString() : "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSave(
      _nameCtrl.text.trim(),
      _breedCtrl.text.trim(),
      _ageCtrl.text.trim().isNotEmpty ? int.tryParse(_ageCtrl.text.trim()) : null,
      widget.initialPhotoUrl, // for now keep photoUrl static
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: "Cat Name *",
              hintText: "e.g. Mochi",
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? "Enter a cat name"
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _breedCtrl,
            decoration: const InputDecoration(
              labelText: "Breed (optional)",
              hintText: "e.g. Persian",
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Age (optional)",
              hintText: "e.g. 3",
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isSaving ? null : _submit,
              child: widget.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Save"),
            ),
          )
        ],
      ),
    );
  }
}
