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
      backgroundColor: const Color(0xFFFFF8F5), // 🌸 soft off-white
      body: SafeArea(
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

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 🐱 Cat Image
                  Hero(
                    tag: catId,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: const Color(0xFFFFE4E1), // light pink bg
                      backgroundImage:
                          (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      child: (photoUrl.isEmpty)
                          ? const Icon(Icons.pets,
                              size: 70, color: Color(0xFF6A1B9A))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🐾 Cat Info
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A148C), // deep muted purple
                    ),
                  ),
                  Text(
                    breed,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 💗 Chips
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      Chip(
                        backgroundColor: const Color(0xFFB3E5FC),
                        label: Text(
                          "Age: $age years",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        avatar: const Icon(Icons.cake, color: Colors.blueAccent),
                      ),
                      const Chip(
                        backgroundColor: Color(0xFFFFB6C1),
                        label: Text("Healthy",
                            style: TextStyle(color: Colors.black87)),
                        avatar: Icon(Icons.favorite, color: Colors.pinkAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 📘 Info Card
                  _buildInfoCard([
                    _buildInfoTile(
                        Icons.restaurant, "Last fed", "8:30 AM (Today)"),
                    _buildInfoTile(Icons.water_drop, "Drank", "150ml remaining"),
                    _buildInfoTile(Icons.cleaning_services, "Litter cleaned",
                        "Yesterday 6:00 PM"),
                  ]),

                  const SizedBox(height: 24),

                  // ✏️ Edit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Cat updated successfully!")),
                          );
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text("Edit Cat"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE93D8), // soft purple
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: .1),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.purple.withValues(alpha: .1),
        child: Icon(icon, color: const Color(0xFF6A1B9A)),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }
}
