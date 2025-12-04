import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/Jersey_Onboarding1_Screen.dart';

class JerseyApp extends StatelessWidget {
  const JerseyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JerseyOnboarding1Screen(),
    );
  }
}