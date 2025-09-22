import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pusa_app/blocs/auth/auth_bloc.dart';
import 'package:pusa_app/screens/onboarding/intro_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider at the top level so ALL routes can access AuthBloc
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: MaterialApp(
        title: 'Pusa Smart Litter',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const IntroScreen(),
      ),
    );
  }
}