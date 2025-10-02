import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pets),
                  label: Text("Cat Profile"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant),
                  label: Text("Feeding"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.delete),
                  label: Text("Litter Box"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list),
                  label: Text("Activity Logs"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text("Settings"),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboard(context),
                  const Center(child: Text("Cat Profile Page")),
                  const Center(child: Text("Feeding Page")),
                  const Center(child: Text("Litter Box Page")),
                  const Center(child: Text("Activity Logs Page")),
                  _buildSettings(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final displayName = state.user.catName ?? state.user.email;
          return Center(
            child: Text(
              "Welcome, $displayName 🐾",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          );
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text("Loading user data..."));
        }
      },
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read<AuthBloc>().add(AuthLogoutRequested());
        },
        child: const Text("Logout"),
      ),
    );
  }
}
