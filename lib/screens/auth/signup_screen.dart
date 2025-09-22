import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/home/home_screen.dart';
import 'package:pusa_app/widgets/auth/signup_form.dart';

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
            final isTablet = constraints.maxWidth >= 600;
            if (!isTablet) {
              return SignupForm(
                emailController: emailController,
                passwordController: passwordController,
                isTablet: false,
              );
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
                    child: SignupForm(
                      emailController: emailController,
                      passwordController: passwordController,
                      isTablet: true,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );  
  }
}
