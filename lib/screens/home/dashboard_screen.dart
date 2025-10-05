import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import '../cats/cat_details_screen.dart';

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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Cat Row
              SizedBox(
                height: 120,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(userId)
                      .collection("cats")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                        final data = cats[index].data() as Map<String, dynamic>?;
                        final catId = cats[index].id;

                        final catName = data?["name"] as String? ?? "Unnamed";
                        final photoUrl = data?["photoUrl"] as String?;

                        return GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Close",
                              barrierColor: Colors.black.withValues(alpha: 0.2),
                              transitionDuration:
                                  const Duration(milliseconds: 250),
                              pageBuilder: (_, __, ___) {
                                return Stack(
                                  children: [
                                    // Blur background
                                    BackdropFilter(
                                      filter:
                                          ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                      child: Container(color: Colors.transparent),
                                    ),
                                    // Bottom popup
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FractionallySizedBox(
                                        heightFactor: 0.7,
                                        child: CatDetailsScreen(
                                          userId: userId,
                                          catId: catId,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              transitionBuilder: (_, animation, __, child) {
                                final curved = CurvedAnimation(
                                    parent: animation, curve: Curves.easeOut);
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 1),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: (photoUrl != null &&
                                          photoUrl.isNotEmpty)
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: (photoUrl == null || photoUrl.isEmpty)
                                      ? const Icon(Icons.pets, size: 35)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 70,
                                  child: Tooltip(
                                    message: catName,
                                    child: Text(
                                      catName,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
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

              const SizedBox(height: 16),
              const Text(
                "Dashboard Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // 🔹 Feeding Card
              DashboardCard(
                title: "Feeding",
                subtitle: "Last meal: Today 8:30 AM",
                icon: Icons.restaurant,
                color: Colors.orange,
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // 🔹 Hydration Card
              DashboardCard(
                title: "Hydration",
                subtitle: "Water level: 75%",
                icon: Icons.water_drop,
                color: Colors.blue,
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // 🔹 Litter Box Card
              DashboardCard(
                title: "Litter Box",
                subtitle: "Last cleaned: Yesterday 6:00 PM",
                icon: Icons.cleaning_services,
                color: Colors.green,
                onTap: () {},
              ),
              const SizedBox(height: 12),

              // 🔹 Logs / History Card
              DashboardCard(
                title: "Activity Logs",
                subtitle: "View feeding, hydration, and litter events",
                icon: Icons.history,
                color: Colors.purple,
                onTap: () {},
              ),
            ],
          ),
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

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withAlpha(40),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
