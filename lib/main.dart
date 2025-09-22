import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusa_app/screens/onboarding/intro_screen.dart';
import 'blocs/auth/auth_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: MaterialApp(
        title: 'Pusa Smart Litter',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const IntroScreen()
      ),
    );
  }
}
