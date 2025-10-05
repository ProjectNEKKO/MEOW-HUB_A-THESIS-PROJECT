import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/cats/edit_cat_screen.dart';

class CatDetailsScreen extends StatelessWidget {
  final String userId;
  final String catId;

  const CatDetailsScreen({
    super.key,
    required this.userId,
    required this.catId,
  });

  @override
  Widget build(BuildContext context) {
    final uid = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withValues(alpha: .95),
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("cats")
                    .doc(catId)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.data();
                  if (data == null) {
                    return const Center(child: Text("No data found"));
                  }

                  final photoUrl = data["photoUrl"]?.toString() ?? "";
                  final name = data["name"]?.toString() ?? "Unknown Cat";
                  final breed = data["breed"]?.toString() ?? "Unknown";
                  final age = data["age"]?.toString() ?? "N/A";

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Hero(
                              tag: catId,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: (photoUrl.isNotEmpty)
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: (photoUrl.isEmpty)
                                    ? const Icon(Icons.pets, size: 60)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              breed,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              children: [
                                Chip(
                                  label: Text("Age: $age years"),
                                  avatar: const Icon(Icons.cake, size: 18),
                                ),
                                const Chip(
                                  label: Text("Healthy"),
                                  avatar: Icon(Icons.favorite, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recent Activity",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildActivityTile(
                                  Icons.restaurant, "Last fed", "8:30 AM"),
                              _buildActivityTile(Icons.water_drop, "Drank",
                                  "150ml remaining"),
                              _buildActivityTile(Icons.cleaning_services,
                                  "Litter cleaned", "Yesterday 6:00 PM"),
                              const SizedBox(height: 24),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditCatScreen(
                                          userId: uid,
                                          catId: catId,
                                          initialName: name,
                                          initialBreed: breed,
                                          initialAge: int.tryParse(age),
                                          initialPhotoUrl: photoUrl,
                                        ),
                                      ),
                                    );
                                    if (updated == true && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Cat updated successfully!")));
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text("Edit Cat"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: .1),
          child: Icon(icon, color: Colors.purple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
