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
          backgroundColor: const Color(0xFFFFFAF0), // 🧡 same as dashboard
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "My Cats 🐾",
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
          ),

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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.pets, size: 60, color: Colors.orange),
                      SizedBox(height: 10),
                      Text(
                        "No cats yet. Add one!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              final cats = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: cats.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
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
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                        color: Colors.white,
                        shadowColor: Colors.purple.withValues(alpha: .1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: Column(
                            children: [
                              Hero(
                                tag: catDoc.id,
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: imageUrl != null
                                      ? NetworkImage(imageUrl)
                                      : null,
                                  backgroundColor: Colors.orange.shade50,
                                  child: imageUrl == null
                                      ? const Icon(Icons.pets,
                                          size: 40, color: Colors.orange)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                cat["name"] ?? "Unnamed Cat",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                cat["breed"] ?? "Unknown Breed",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.info_outline,
                                        size: 18, color: Colors.orange),
                                    label: const Text(
                                      "View",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CatDetailsScreen(
                                            userId: user.uid,
                                            catId: catDoc.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 20, color: Colors.purple),
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
                                                "Cat updated successfully!"),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          floatingActionButton: FloatingActionButton.extended(
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
            icon: const Icon(Icons.add),
            label: const Text("Add Cat"),
          ),
        );
      },
    );
  }
}
