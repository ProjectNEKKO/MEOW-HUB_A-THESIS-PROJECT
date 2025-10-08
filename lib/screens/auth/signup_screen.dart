import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';
import 'package:pusa_app/screens/onboarding/cat_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signup(BuildContext context) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(AuthSignupRequested(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileIncomplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CatSetupScreen()),
          );
        } else if (state is AuthError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 700;

          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFF5F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isWide
                  ? Row(
                      children: [
                        // Left branding panel
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(48),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF81D4FA), Color(0xFFB3E5FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Soft floating circles
                                Positioned(
                                  top: 80,
                                  left: 40,
                                  child: _buildBlurCircle(
                                    120,
                                    Colors.white.withValues(alpha: .3),
                                  ),
                                ),
                                Positioned(
                                  bottom: 100,
                                  right: 60,
                                  child: _buildBlurCircle(
                                    160,
                                    Colors.white.withValues(alpha: .2),
                                  ),
                                ),

                                // Branding content
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: const [
                                          Text("🐱",
                                              style: TextStyle(fontSize: 40)),
                                          SizedBox(width: 12),
                                          Text(
                                            "Pusa",
                                            style: TextStyle(
                                              fontSize: 46,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF01579B),
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),

                                      const Text(
                                        "Smart Pet Care Simplified",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0277BD),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      const Text(
                                        "Automate feeding, hydration, and litter insights —\nso you can focus on cuddles, not chores 💙",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF0D47A1),
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      // Optional illustration
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Opacity(
                                            opacity: 0.15,
                                            child: Image.asset(
                                              'lib/assets/images/cat_login1.png',
                                              height: 200,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right form panel
                        Expanded(
                          flex: 3,
                          child: _buildSignupCard(context),
                        ),
                      ],
                    )
                  : Center(child: _buildSignupCard(context)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .6),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupCard(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          color: Colors.white.withValues(alpha: .95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "🐾 Join the Pusa Family!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create your account and start caring smart 💙",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildTextField(
                    controller: nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _signup(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Sign Up",
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Log In",
                      style: TextStyle(
                        color: Color(0xFF0288D1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF0288D1)),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFB3E5FC).withValues(alpha: .15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
