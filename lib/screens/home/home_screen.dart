import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';

import 'cat_profile_screen.dart';
import 'feeding_screen.dart';
import 'hydration_screen.dart';
import 'litter_screen.dart';
import 'logs_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CatProfileScreen(),
    FeedingScreen(),
    HydrationScreen(),
    LitterScreen(),
    LogsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // ✅ Redirect to Login when logged out
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
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,

              // ✅ Header
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: const [
                    Icon(Icons.pets, size: 40, color: Colors.purple),
                    SizedBox(height: 8),
                    Text(
                      "Pusa App",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ✅ prevent overflow
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      tooltip: "Logout",
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                    const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.pets),
                  label: Text("Cat Profile"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.restaurant),
                  label: Text("Feeding"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.water_drop),
                  label: Text("Hydration"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.cleaning_services),
                  label: Text("Litter"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history),
                  label: Text("Logs"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text("Settings"),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
