import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isTablet;

  const SignupForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(
                AuthSignupRequested(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                ),
              );
            },
            child: const Text("Sign Up"),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
