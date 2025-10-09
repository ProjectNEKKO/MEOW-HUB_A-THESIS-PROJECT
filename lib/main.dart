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

  // Start Firebase asynchronously (don’t block UI)
  final firebaseInit = Firebase.initializeApp();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('ledBox');
  await Hive.openBox('ledLogs');

  // Get onboarding flag
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Run app while Firebase finishes in background
  runApp(
    FutureBuilder(
      future: firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp(hasSeenOnboarding: hasSeenOnboarding);
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Firebase failed to initialize')),
            ),
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    ),
  );
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
