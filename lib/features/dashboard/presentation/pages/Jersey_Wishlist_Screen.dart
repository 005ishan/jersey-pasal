import 'package:flutter/material.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';

class JerseyWishlistScreen extends StatelessWidget {
  const JerseyWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: JerseyAppBar(),
      body: const Center(
        child: Text(
          'Welcome to Wishlist Screen',
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
