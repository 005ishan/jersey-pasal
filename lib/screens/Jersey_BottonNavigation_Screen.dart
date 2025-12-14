import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';


class JerseyBottonnavigationScreen extends StatefulWidget {
  const JerseyBottonnavigationScreen({super.key});

  @override
  State<JerseyBottonnavigationScreen> createState() => _JerseyBottonnavigationScreenState();
}

class _JerseyBottonnavigationScreenState extends State<JerseyBottonnavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.blue,
            color: Colors.white,
            activeColor: const Color.fromARGB(255, 0, 0, 0),
            tabBackgroundColor: Colors.white,
            padding: EdgeInsetsGeometry.all(16),
            gap: 8,
            tabs: const[
              GButton(icon: Icons.home, text: "Home",),
              GButton(icon: Icons.favorite, text:  "Wishlist",),
              GButton(icon: Icons.shopping_bag, text: "Cart",),
              GButton(icon: Icons.person, text: "Profile",)
            ],
          ),
        ),
      ),
    );
  }
}