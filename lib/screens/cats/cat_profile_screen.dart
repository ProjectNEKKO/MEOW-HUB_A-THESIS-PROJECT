import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/cats/add_cat_screen.dart';
import 'package:pusa_app/screens/cats/edit_cat_screen.dart';
import 'package:pusa_app/screens/cats/cat_details_screen.dart';

class CatProfileScreen extends StatelessWidget {
  const CatProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Center(child: Text("Not logged in"));
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(title: const Text("My Cats")),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .collection("cats")
                .orderBy("updatedAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No cats yet. Add one!"));
              }

              final cats = snapshot.data!.docs;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight;
                  // Adjust card proportions based on available height
                  final isShortScreen = screenHeight < 700;
                  final aspectRatio = isShortScreen ? 0.9 : 0.75;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: cats.length,
                    itemBuilder: (context, index) {
                      final catDoc = cats[index];
                      final cat = catDoc.data() as Map<String, dynamic>;

                      final imageUrl = (cat["photoUrl"] != null &&
                              cat["photoUrl"].toString().isNotEmpty)
                          ? cat["photoUrl"]
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CatDetailsScreen(
                                userId: user.uid,
                                catId: catDoc.id,
                                catData: cat,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),
                              CircleAvatar(
                                radius: 38,
                                backgroundImage: imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl == null
                                    ? const Icon(Icons.pets, size: 38)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                cat["name"] ?? "Unnamed Cat",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat["breed"] ?? "Unknown Breed",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.info, size: 18),
                                      label: const Text("View"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CatDetailsScreen(
                                              userId: user.uid,
                                              catId: catDoc.id,
                                              catData: cat,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () async {
                                        final updated = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditCatScreen(
                                              userId: user.uid,
                                              catId: catDoc.id,
                                              initialName: cat["name"] ?? "",
                                              initialBreed: cat["breed"],
                                              initialAge: cat["age"],
                                              initialPhotoUrl: cat["photoUrl"],
                                            ),
                                          ),
                                        );

                                        if (updated == true && context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Cat updated successfully!")),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCatScreen()),
              );

              if (added == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cat added successfully!")),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
