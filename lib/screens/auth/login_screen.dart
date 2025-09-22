import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/home/home_screen.dart';
import 'package:pusa_app/widgets/auth/login_form.dart';

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
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            return isTablet
                ? Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            "🐾 Welcome Back!",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LoginForm(
                          emailController: emailController,
                          passwordController: passwordController,
                          isTablet: true,
                        ),
                      ),
                    ],
                  )
                : LoginForm(
                    emailController: emailController,
                    passwordController: passwordController,
                    isTablet: false,
                  );
          },
        ),
      ),
    );
  }
}