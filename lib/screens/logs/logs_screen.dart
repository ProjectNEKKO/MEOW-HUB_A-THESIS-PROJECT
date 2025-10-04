import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "📜 Activity Logs Content",
        style: TextStyle(fontSize: 22),
      ),
    );
  }
}
