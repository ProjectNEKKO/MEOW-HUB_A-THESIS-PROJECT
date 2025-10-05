import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/home/esp32_test_screen.dart';
import '../cats/cat_details_screen.dart';
import '../home/feeding_screen.dart';
import '../home/hydration_screen.dart';
//import '../home/litter_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: Text("Not logged in"));
        }

        final userId = state.user.uid;

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🐾 Cat Story Circles
                    SizedBox(
                      height: 120,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("users")
                            .doc(userId)
                            .collection("cats")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "No cats yet. Add one in Cat Profile.",
                                style: TextStyle(fontSize: 14),
                              ),
                            );
                          }
                          final cats = snapshot.data!.docs;
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: cats.length,
                            itemBuilder: (context, index) {
                              final data =
                                cats[index].data() as Map<String, dynamic>?;
                              final catId = cats[index].id;
                              final catName =
                                data?["name"] as String? ?? "Unnamed";
                              final photoUrl = data?["photoUrl"] as String? ?? "";
                              return Padding(
                                padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                      context: context,
                                      expand: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => CatDetailsScreen(
                                        userId: userId,
                                        catId: catId,
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Hero(
                                        tag: catId,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF9C27B0),
                                                Color(0xFFFF9800)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple
                                                    .withAlpha(60),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundImage:
                                                (photoUrl.isNotEmpty)
                                                    ? NetworkImage(photoUrl)
                                                    : null,
                                            child: (photoUrl.isEmpty)
                                                ? const Icon(Icons.pets,
                                                    size: 35)
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          catName,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Dashboard Overview",
                      style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: DashboardCard(
                          title: "Litter Box",
                          subtitle: "Last cleaned: Yesterday 6:00 PM",
                          icon: Icons.cleaning_services,
                          color: Colors.green,
                          isLarge: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Esp32TestScreen()),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: "Feeding",
                            subtitle: "Last meal: Today 8:30 AM",
                            icon: Icons.restaurant,
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FeedingScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DashboardCard(
                            title: "Hydration",
                            subtitle: "Water level: 75%",
                            icon: Icons.water_drop,
                            color: Colors.blue,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HydrationScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DashboardCard(
                      title: "Activity Logs",
                      subtitle:
                          "View feeding, hydration, and litter events",
                      icon: Icons.history,
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Use the Logs tab to view history")),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isLarge ? 24.0 : 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: isLarge ? 35 : 28,
                backgroundColor: color.withAlpha(40),
                child: Icon(icon, size: isLarge ? 35 : 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: isLarge ? 20 : 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
