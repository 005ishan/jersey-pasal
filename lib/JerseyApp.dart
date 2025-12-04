import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/Jersey_Splash_Screen.dart';

class JerseyApp extends StatelessWidget {
  const JerseyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JerseySplashScreen(),
    );
  }
}