import 'package:flutter/material.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    "Welcome to Pusa 🐾",
    "Smart Feeding & Drinking",
    "AI-powered Litter Insights",
  ];

  final List<String> _subtitles = [
    "Your all-in-one app for your cat’s health.",
    "Automated feeder & water for worry-free days.",
    "Track and analyze your cat’s litter data.",
  ];

  void _nextPage() {
    if (_currentPage < _titles.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _titles.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pets, size: 100, color: Colors.blue),
                      const SizedBox(height: 20),
                      Text(
                        _titles[index],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _subtitles[index],
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _nextPage,
            child: Text(
              _currentPage == _titles.length - 1 ? "Get Started" : "Next",
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
