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
          backgroundColor: const Color(0xFFFFF9F9),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(18.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: screenHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🐾 Welcome Header
                        Row(
                          children: [
                            const Icon(Icons.pets, color: Color(0xFFF48FB1), size: 28),
                            const SizedBox(width: 8),
                            Text(
                              "Welcome back, ${state.user.displayName ?? "Cat Parent"}!",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Here’s how your cats are doing today 🐾",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D8D8D),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 🐱 Cat Circles
                        SizedBox(
                          height: 120,
                          child: (userId.isEmpty)
                              ? const Center(child: Text("Please log in to view your cats 🐾"))
                              : StreamBuilder<QuerySnapshot>(
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
                                    style: TextStyle(fontSize: 14, color: Color(0xFF8D8D8D)),
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
                                  final catName = data?["name"] ?? "Unnamed";
                                  final photoUrl = data?["photoUrl"] ?? "";

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
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: const LinearGradient(
                                                  colors: [Color(0xFFF8BBD0), Color(0xFFB3E5FC)],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.pinkAccent.withValues(alpha: .2),
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
                                                backgroundColor: const Color(0xFFFFF3E0),
                                                child: (photoUrl.isEmpty)
                                                    ? const Icon(Icons.pets, color: Colors.pinkAccent, size: 32)
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            catName,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF5D4037),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
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

                        // 🌈 Status Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildStatusChip("Feeder", true),
                            _buildStatusChip("Hydration", true),
                            _buildStatusChip("Litter", false),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // 🩵 Summary Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF3E0), Color(0xFFFFF9F9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.pinkAccent.withValues(alpha: .05),
                                blurRadius: 6,
                              ),
                            ],
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

                        // 🐾 Divider
                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 1.2, color: Color(0xFFF8BBD0))),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("🐾", style: TextStyle(fontSize: 18)),
                            ),
                            Expanded(child: Divider(thickness: 1.2, color: Color(0xFFB3E5FC))),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Dashboard Overview",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5D4037),
                          ),
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
                              color: Color(0xFFF8BBD0),
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
                                color: Color(0xFFF48FB1),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const FeedingScreen()),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DashboardCard(
                                title: "Hydration",
                                subtitle: "Water level: 75%",
                                icon: Icons.water_drop,
                                color: Color(0xFFB3E5FC),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const HydrationScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DashboardCard(
                          title: "Activity Logs",
                          subtitle: "View feeding, hydration, and litter events",
                          icon: Icons.history,
                          color: Color(0xFFCE93D8),
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

Widget _buildStatusChip(String label, bool online) {
  final color = online ? const Color(0xFFB3E5FC) : const Color(0xFFF8BBD0);
  final icon = online ? Icons.check_circle : Icons.cancel;

  return Chip(
    avatar: Icon(icon, color: online ? Colors.blueAccent : Colors.pinkAccent, size: 18),
    label: Text("$label ${online ? "Online" : "Offline"}"),
    backgroundColor: color.withValues(alpha: .3),
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
        Icon(icon, color: Color(0xFFF48FB1), size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5D4037))),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8D8D8D))),
      ],
    );
  }
}

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [widget.color.withValues(alpha: .2), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.all(widget.isLarge ? 24.0 : 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: widget.isLarge ? 35 : 28,
                  backgroundColor: widget.color.withValues(alpha: .25),
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
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D4037),
                          )),
                      const SizedBox(height: 4),
                      Text(widget.subtitle,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF8D8D8D))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8D8D8D)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
