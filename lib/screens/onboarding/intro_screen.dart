import 'package:flutter/material.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    "Smart Feeding & Hydration",
    "AI-Powered Litter Insights",
  ];

  final List<String> _subtitles = [
    "Your all-in-one app for your cat’s wellness and happiness.",
    "Automated feeding and hydration — because your furry friend deserves the best care.",
    "Track, analyze, and understand your cat’s litter habits with intelligent monitoring.",
  ];

  final List<String> _images = [
    "assets/images/intro_cat1.png", // replace with your illustrations
    "assets/images/intro_cat2.png",
    "assets/images/intro_cat3.png",
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _titles.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF5F8), Color(0xFFF2F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _titles.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image / illustration
                          Expanded(
                            flex: 4,
                            child: Image.asset(
                              _images[index],
                              fit: BoxFit.contain,
                              height: 260,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Title
                          Text(
                            _titles[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A148C),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Subtitle
                          Text(
                            _subtitles[index],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6A1B9A),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_titles.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? const Color(0xFFBA68C8)
                          : Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Next / Get Started Button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCE93D8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _currentPage == _titles.length - 1
                          ? "Get Started"
                          : "Next",
                      style: const TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
