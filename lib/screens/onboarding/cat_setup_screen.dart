import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  void _saveProfile(AppUser currentUser) {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = currentUser.copyWith(
      catName: _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      introCompleted: true,
    );

    setState(() => _isSaving = true);

    context.read<AuthBloc>().add(UpdateProfileRequested(updatedUser));
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tell us about your cat',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Cat name *',
                              hintText: 'e.g. Mochi',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter a name'
                                : null,
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
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
