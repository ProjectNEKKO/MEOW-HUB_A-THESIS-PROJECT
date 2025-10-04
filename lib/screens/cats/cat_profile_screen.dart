import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/cats/add_cat_screen.dart';
import 'package:pusa_app/screens/cats/edit_cat_screen.dart';

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

              return ListView.builder(
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  final cat = cats[index].data() as Map<String, dynamic>;
                  return ListTile(
                    leading: const Icon(Icons.pets, size: 32),
                    title: Text(cat["name"] ?? "Unnamed Cat"),
                    subtitle: Text(cat["breed"] ?? "Unknown Breed"),
                    onTap: () {
                      // TODO: Navigate to CatDetailsScreen
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCatScreen(catId: cats[index].id),
                          ),
                        );

                        if (updated == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Cat updated successfully!")),
                          );
                        }
                      },
                    ),
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
