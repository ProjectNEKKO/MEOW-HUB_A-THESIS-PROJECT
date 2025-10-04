import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';

class CatDetailsScreen extends StatelessWidget {
  final String catId;
  const CatDetailsScreen({super.key, required this.catId});

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.uid;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // ✅ blur HomeScreen
      child: Material(
        color: Colors.black.withValues(alpha: 0.3), // ✅ translucent background
        child: DraggableScrollableSheet(
          initialChildSize: 0.55, // start height
          minChildSize: 0.4,      // how small it can shrink
          maxChildSize: 0.9,      // how tall it can expand
          builder: (context, scrollController) {
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("cats")
                  .doc(catId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data();
                if (data == null) {
                  return const Center(child: Text("Cat not found"));
                }

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: scrollController, // ✅ makes sheet draggable
                    padding: const EdgeInsets.all(20),
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
                          radius: 50,
                          backgroundImage: data["photoUrl"] != null
                              ? NetworkImage(data["photoUrl"])
                              : null,
                          child: data["photoUrl"] == null
                              ? const Icon(Icons.pets, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cat name
                      Center(
                        child: Text(
                          data["name"] ?? "Unknown",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Cat details
                      Center(
                        child: Text("Breed: ${data['breed'] ?? 'Unknown'}"),
                      ),
                      if (data["age"] != null)
                        Center(child: Text("Age: ${data['age']} years")),

                      const SizedBox(height: 24),

                      // Close button
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text("Close"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
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
