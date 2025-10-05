import 'package:flutter/material.dart';

class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feeding Details"),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Text(
          "🍽 Feeding Content",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
