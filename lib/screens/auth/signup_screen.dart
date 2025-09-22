import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/home/home_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (state is AuthUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup Failed!")),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Sign Up")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildSignupForm(context, emailController, passwordController, false);
            } else {
              return Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "🐾 Create Your Pusa Account",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildSignupForm(context, emailController, passwordController, true),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );  
  }

  Widget _buildSignupForm(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    bool isTablet,
  ) {
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Already have an account? Login"),
          ),
        ],
      ),
    );
  }
}
