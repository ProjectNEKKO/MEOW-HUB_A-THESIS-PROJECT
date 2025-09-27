import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/screens/auth/signup_screen.dart';
import 'package:pusa_app/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed, check credentials")),
          );
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Left side panel (branding / welcome message)
            Expanded(
              child: Center(
                child: Text(
                  "🐾 Welcome Back to Pusa",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            // Right side panel (form)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              ),
                            );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text("Don’t have an account? Sign up"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
