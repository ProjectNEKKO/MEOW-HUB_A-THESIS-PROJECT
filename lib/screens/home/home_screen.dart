import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';
import 'package:pusa_app/screens/home/dashboard_screen.dart';

import '../cats/cat_profile_screen.dart';
import 'feeding_screen.dart';
import 'hydration_screen.dart';
import 'litter_screen.dart';
import '../logs/logs_screen.dart';
import '../settings/settings_screen.dart';
import '../cats/cat_details_screen.dart';

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
            // ✅ Left Navigation Rail
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: const [
                    Icon(Icons.pets, size: 40, color: Colors.purple),
                    SizedBox(height: 8),
                    Text("Pusa App", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      tooltip: "Logout",
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                    const Text("Logout", style: TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text("Home"),
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

            // ✅ Main content
            Expanded(
              child: Column(
                children: [
                  // --- Cat circles row (Instagram style) ---
                  SizedBox(
                    height: 120,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is! AuthAuthenticated) {
                          return const SizedBox();
                        }
                        final userId = state.user.uid;

                        return StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .collection("cats")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final cats = snapshot.data!.docs;

                            if (cats.isEmpty) {
                              return const Center(
                                child: Text("No cats yet. Add one in Cat Profile."),
                              );
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cats.length,
                              itemBuilder: (context, index) {
                                final cat = cats[index].data();
                                return GestureDetector(
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: "Close",
                                      barrierColor: Colors.black.withValues(alpha: 0.2), // semi-dark overlay
                                      transitionDuration: const Duration(milliseconds: 250),
                                      pageBuilder: (_, __, ___) {
                                        return Stack(
                                          children: [
                                            // 🔹 Blur the HomeScreen behind
                                            BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                              child: Container(color: Colors.transparent),
                                            ),

                                            // 🔹 Bottom popup sheet
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: FractionallySizedBox(
                                                heightFactor: 0.7, // takes 70% of screen
                                                child: CatDetailsScreen(catId: cats[index].id),
                                              ),
                                            ),
                                          ],
                                        );
                                      },

                                      transitionBuilder: (_, animation, __, child) {
                                        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, 1), // starts from bottom
                                            end: Offset.zero,
                                          ).animate(curved),
                                          child: FadeTransition(
                                            opacity: curved,
                                            child: child,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 35,
                                          backgroundImage: cat["photoUrl"] != null
                                              ? NetworkImage(cat["photoUrl"])
                                              : null,
                                          child: cat["photoUrl"] == null
                                              ? const Icon(Icons.pets, size: 35)
                                              : null,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cat["name"] ?? "Unnamed",
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // --- Dashboard body (your selected page) ---
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
