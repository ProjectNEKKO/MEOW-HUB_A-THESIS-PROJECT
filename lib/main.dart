import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/blocs/auth/auth_event.dart';
import 'package:pusa_app/blocs/auth/auth_state.dart';
import 'package:pusa_app/screens/onboarding/intro_screen.dart';
import 'package:pusa_app/screens/home/home_screen.dart';
import 'package:pusa_app/screens/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧩 Initialize Firebase
  await Firebase.initializeApp();

  // 🐝 Initialize Hive (local storage)
  await Hive.initFlutter();
  await Hive.openBox('ledBox');   // For ESP32 LED state
  await Hive.openBox('ledLogs');  // For LED toggle history

  // 🔹 Check onboarding completion
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc()..add(const AuthCheckRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pusa Smart Litter',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.grey.shade50,
          fontFamily: 'Poppins',
        ),
        home: hasSeenOnboarding
            ? BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading || state is AuthInitial) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is AuthAuthenticated) {
                    return const HomeScreen();
                  } else {
                    return const LoginScreen();
                  }
                },
              )
            : const IntroScreen(),
      ),
    );
  }
}
