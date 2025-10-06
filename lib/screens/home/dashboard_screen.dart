import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';

import '../cats/cat_details_screen.dart';
import '../home/feeding_screen.dart';
import '../home/hydration_screen.dart';
import '../home/litter_screen.dart';

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

        return Scaffold(
          backgroundColor: const Color(0xFFFFFAF0),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🐾 Welcome Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.pets, color: Colors.orange, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                "Welcome back, ${state.user.displayName ?? "Cat Parent"}!",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Here’s how your cats are doing today 🐾",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),

                        const SizedBox(height: 20),

                        // 🐱 Cat Circles
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
                                  final photoUrl = data?["photoUrl"] as String? ?? "";

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                              duration: const Duration(milliseconds: 300),
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFF9C27B0), Color(0xFFFF9800)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple.withAlpha(60),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 35,
                                                backgroundImage: (photoUrl.isNotEmpty)
                                                    ? NetworkImage(photoUrl)
                                                    : null,
                                                child: (photoUrl.isEmpty)
                                                    ? const Icon(Icons.pets, size: 35)
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

                        const SizedBox(height: 20),

                        // 🌈 Status Chips
                        Wrap(
                          spacing: 10,
                          children: [
                            _buildStatusChip("Feeder", true),
                            _buildStatusChip("Hydration", true),
                            _buildStatusChip("Litter", false),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 🧡 Today's Summary
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              _SummaryItem(icon: Icons.restaurant, label: "Meals", value: "2"),
                              _SummaryItem(icon: Icons.water_drop, label: "Water", value: "75%"),
                              _SummaryItem(icon: Icons.cleaning_services, label: "Clean", value: "1x"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🐾 Section Divider
                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 1.2)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("🐾", style: TextStyle(fontSize: 18)),
                            ),
                            Expanded(child: Divider(thickness: 1.2)),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "Dashboard Overview",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        // 🧩 Cards
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
                                  MaterialPageRoute(builder: (_) => const LitterScreen()),
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
                                    MaterialPageRoute(builder: (_) => const FeedingScreen()),
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
                                    MaterialPageRoute(builder: (_) => const HydrationScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DashboardCard(
                          title: "Activity Logs",
                          subtitle: "View feeding, hydration, and litter events",
                          icon: Icons.history,
                          color: Colors.purple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Use the Logs tab to view history")),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// 🌿 Components

Widget _buildStatusChip(String label, bool online) {
  return Chip(
    avatar: Icon(
      online ? Icons.check_circle : Icons.cancel,
      color: online ? Colors.green : Colors.red,
      size: 18,
    ),
    label: Text("$label ${online ? "Online" : "Offline"}"),
    backgroundColor: online ? Colors.green.shade50 : Colors.red.shade50,
  );
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// 🧩 Dashboard Card
class DashboardCard extends StatefulWidget {
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
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isTapped ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isTapped = true),
        onTapUp: (_) {
          setState(() => _isTapped = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isTapped = false),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [widget.color.withOpacity(0.06), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(widget.isLarge ? 24.0 : 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: widget.isLarge ? 35 : 28,
                  backgroundColor: widget.color.withAlpha(40),
                  child: Icon(widget.icon, size: widget.isLarge ? 35 : 28, color: widget.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: TextStyle(
                              fontSize: widget.isLarge ? 20 : 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(widget.subtitle,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
