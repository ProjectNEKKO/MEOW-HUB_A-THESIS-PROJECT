import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated || state is AuthInitial) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _buildHomeContent(context, false);
            } else {
              return Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "🐾 Pusa App",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildHomeContent(context, true),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? 32 : 16),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final displayName = state.user.catName ?? state.user.email;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, $displayName 🐾",
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  child: const Text("Logout"),
                ),
              ],
            );
          } else if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Text("Loading user data...");
          }
        },
      ),
    );
  }
}
