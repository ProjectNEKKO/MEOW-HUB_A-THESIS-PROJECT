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
        color: Colors.black.withValues(alpha: 0.3),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
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

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Handle bar
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

                      // Cat photo
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              (photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty
                              ? const Icon(Icons.pets, size: 60)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cat name
                      Center(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Breed + Age
                      Center(
                        child: Text(
                          "Breed: $breed",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (age != null)
                        Center(
                          child: Text(
                            "Age: $age years",
                            style: const TextStyle(fontSize: 16),
                          ),
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
                                          Text("Cat updated successfully!")),
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
