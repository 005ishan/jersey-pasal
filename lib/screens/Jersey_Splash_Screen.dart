import 'package:flutter/material.dart';
import 'Jersey_Onboarding1_Screen.dart';

class JerseySplashScreen extends StatefulWidget {
  const JerseySplashScreen({super.key});

  @override
  State<JerseySplashScreen> createState() => _JerseySplashScreenState();
}

class _JerseySplashScreenState extends State<JerseySplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const JerseyOnboarding1Screen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 25),

            const Text(
              'JERSEYपसल',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Authentic Football Jerseys',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
