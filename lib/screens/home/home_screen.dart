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
    const primaryPink = Color.fromARGB(255, 249, 197, 203);
    const secondaryBlue = Color(0xFFC8E6F5);
    const lavenderAccent = Color(0xFFD4C1EC);
    const backgroundCream = Color(0xFFFFFDFC);
    const textDark = Color(0xFF333333);

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
        backgroundColor: backgroundCream,
        body: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: primaryPink,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                extended: true,
                minExtendedWidth: 210,
                backgroundColor: primaryPink,
                indicatorColor: lavenderAccent.withValues(alpha: .5),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                groupAlignment: -1.0,

                // 🐱 Logo Section
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.pets, size: 30, color: Color(0xFFB388EB)),
                      SizedBox(width: 8),
                      Text(
                        "Pusa App",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // 😿 Logout Button
                trailing: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.pink.shade100,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: backgroundCream,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: const [
                                  Icon(Icons.pets, color: Color(0xFFB388EB), size: 28),
                                  SizedBox(width: 8),
                                  Text(
                                    "Time for a cat nap?",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                              content: const Text(
                                "Your cat 🐾 will be waiting for snuggles!\nDo you want to log out?",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: textDark),
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  style: TextButton.styleFrom(
                                    backgroundColor: secondaryBlue.withValues(alpha: .3),
                                    foregroundColor: textDark,
                                  ),
                                  child: const Text("Stay 😺"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: lavenderAccent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Logout 😿"),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            children: const [
                              Icon(Icons.logout, color: Colors.pinkAccent),
                              SizedBox(width: 10),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 💗 Navigation Buttons
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined, color: textDark),
                    selectedIcon: Icon(Icons.dashboard, color: Color(0xFFB388EB)),
                    label: Text("Dashboard"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.pets_outlined, color: textDark),
                    selectedIcon: Icon(Icons.pets, color: Color(0xFFB388EB)),
                    label: Text("Cat Profile"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history_outlined, color: textDark),
                    selectedIcon: Icon(Icons.history, color: Color(0xFFB388EB)),
                    label: Text("Logs"),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined, color: textDark),
                    selectedIcon: Icon(Icons.settings, color: Color(0xFFB388EB)),
                    label: Text("Settings"),
                  ),
                ],
                selectedLabelTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB388EB),
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: textDark,
                ),
              ),
            ),

            const VerticalDivider(width: 1, thickness: 0.8, color: Color(0xFFEADFF5)),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }
}
