import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/widgets/JerseyAppBar.dart';


class JerseyHomeScreen extends StatelessWidget {
  const JerseyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: JerseyAppBar(),
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
