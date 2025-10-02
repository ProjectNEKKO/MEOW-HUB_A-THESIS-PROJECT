import 'package:flutter/material.dart';
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

  final List<String> _titles = const [
    "Cat Profile",
    "Feeding",
    "Hydration",
    "Litter",
    "Activity Logs",
    "Settings",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
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
    );
  }
}
