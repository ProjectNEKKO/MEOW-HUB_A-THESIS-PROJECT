import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';
import 'package:pusa_app/screens/home/dashboard_screen.dart';
import '../cats/cat_profile_screen.dart';
import '../logs/logs_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    CatProfileScreen(),
    LogsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
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
            // 🔹 Left Navigation
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },

              // 🌈 Wider + inline label layout
              extended: true,
              minExtendedWidth: 220,
              backgroundColor: Colors.grey.shade50,
              elevation: 4,
              groupAlignment: -1.0,

              // ✨ Top section (logo/title)
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.pets, size: 34, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      "Pusa App",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),

              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(thickness: 1, indent: 20, endIndent: 20),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Row(
                                children: const [
                                  Icon(Icons.pets, color: Colors.purple, size: 30),
                                  SizedBox(width: 8),
                                  Text(
                                    "Leaving so soon?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "Your cat 🐱 will miss you!\nAre you sure you want to log out?",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
                                ],
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actionsPadding: const EdgeInsets.only(bottom: 16),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                  ),
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Stay 🐾"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                    elevation: 3,
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Logout 😿"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          }
                        },
                        hoverColor: Colors.red.withOpacity(0.1),
                        splashColor: Colors.red.withOpacity(0.15),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: const [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 10),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard, color: Colors.purple),
                  label: Text("Dashboard"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.pets_outlined),
                  selectedIcon: Icon(Icons.pets, color: Colors.purple),
                  label: Text("Cat Profile"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history, color: Colors.purple),
                  label: Text("Logs"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings, color: Colors.purple),
                  label: Text("Settings"),
                ),
              ],

              // 🎨 Highlight indicator (rounded rectangle)
              indicatorColor: Colors.purple.withValues(alpha: .1),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedLabelTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.black87,
              ),
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
