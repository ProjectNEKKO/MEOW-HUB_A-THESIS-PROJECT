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
  final Map<String, dynamic>? catData;

  const CatDetailsScreen({
    super.key,
    required this.userId,
    required this.catId,
    this.catData,
  });

  @override
  Widget build(BuildContext context) {
    final uid = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Material(
        color: Colors.transparent,
        child: DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
              future: catData == null
                  ? FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .collection("cats")
                      .doc(catId)
                      .get()
                  : Future.value(null),
              builder: (context, snapshot) {
                final data = catData ?? snapshot.data?.data();

                if (data == null && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final photoUrl = data?["photoUrl"]?.toString() ?? "";
                final name = data?["name"]?.toString() ?? "Unknown Cat";
                final breed = data?["breed"]?.toString() ?? "Unknown";
                final age = data?["age"];
                final bgColor = Colors.white.withOpacity(0.85);

                return ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: bgColor,
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // 🐱 Cat Photo
                          Hero(
                            tag: catId,
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: (photoUrl.isNotEmpty)
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl.isEmpty
                                  ? const Icon(Icons.pets, size: 60)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🐾 Cat Name
                          Center(
                            child: Text(
                              name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 🧬 Breed & Age Chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                avatar:
                                    const Icon(Icons.pets, size: 18, color: Colors.white),
                                label: Text("Breed: $breed"),
                                backgroundColor: Colors.purple,
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              if (age != null)
                                Chip(
                                  avatar: const Icon(Icons.cake,
                                      size: 18, color: Colors.white),
                                  label: Text("Age: $age years"),
                                  backgroundColor: Colors.orange,
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // 📊 Stats Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat("Meals", "3x/day", Icons.restaurant),
                              _buildStat("Water", "75%", Icons.water_drop),
                              _buildStat("Litter", "Clean", Icons.cleaning_services),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                                label: const Text("Close"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditCatScreen(
                                        userId: uid,
                                        catId: catId,
                                        initialName: name,
                                        initialBreed: breed,
                                        initialAge: age,
                                        initialPhotoUrl: photoUrl,
                                      ),
                                    ),
                                  );

                                  if (updated == true && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Cat updated successfully!"),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
