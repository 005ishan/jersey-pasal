import 'package:flutter/material.dart';
import 'package:jerseypasal/core/widgets/Jersey_Splash_Screen.dart';
import 'package:jerseypasal/app/theme/theme_data.dart';

class JerseyApp extends StatelessWidget {
  const JerseyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: jerseyAppTheme(),
      home: JerseySplashScreen(),
    );
  }
}
