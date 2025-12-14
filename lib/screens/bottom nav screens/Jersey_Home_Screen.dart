import 'package:flutter/material.dart';


class JerseyHomeScreen extends StatelessWidget {
  const JerseyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.primaryColor,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Welcome to Home Screen',
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
