import 'package:flutter/material.dart';

class FeedingScreen extends StatelessWidget {
  const FeedingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "🍽 Feeding Content",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
