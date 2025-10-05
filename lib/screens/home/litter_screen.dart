import 'package:flutter/material.dart';

class LitterScreen extends StatelessWidget {
  const LitterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Litter Box Details"),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          "🧹 Litter Content",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
