import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/home/home_screen.dart';
import 'package:pusa_app/widgets/auth/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            const SnackBar(content: Text("Invalid Credentials")),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Login")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            if (!isTablet) {
              return LoginForm(
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
              );
            }
          },
        ),
      ),
    );
  }
}
