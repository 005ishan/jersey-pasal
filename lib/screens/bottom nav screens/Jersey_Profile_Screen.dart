import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/widgets/JerseyAppBar.dart';

class JerseyProfileScreen extends StatelessWidget {
  const JerseyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JerseyAppBar(),
      body: const Center(
        child: Text(
          'Welcome to Profile Screen',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
