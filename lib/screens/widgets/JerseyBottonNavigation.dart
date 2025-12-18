import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jerseypasal/screens/bottom nav screens/Jersey_Cart_Screen.dart';
import 'package:jerseypasal/screens/bottom nav screens/Jersey_Home_Screen.dart';
import 'package:jerseypasal/screens/bottom nav screens/Jersey_Profile_Screen.dart';
import 'package:jerseypasal/screens/bottom nav screens/Jersey_Wishlist_Screen.dart';

class JerseyBottomNavigation extends StatefulWidget {
  const JerseyBottomNavigation({super.key});

  @override
  State<JerseyBottomNavigation> createState() =>
      _JerseyBottomNavigationState();
}

class _JerseyBottomNavigationState
    extends State<JerseyBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _bottomScreens = const [
    JerseyHomeScreen(),
    JerseyWishlistScreen(),
    JerseyCartScreen(),
    JerseyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _bottomScreens[_selectedIndex],
      bottomNavigationBar: Container(
        color: Color(0xFF1877F2),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: GNav(
          backgroundColor: Color(0xFF1877F2),
          color: Colors.white,
          activeColor: Colors.black,
          tabBackgroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
          gap: 8,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          tabs: const [
            GButton(icon: Icons.home, text: "Home"),
            GButton(icon: Icons.favorite, text: "Wishlist"),
            GButton(icon: Icons.shopping_bag, text: "Cart"),
            GButton(icon: Icons.person, text: "Profile"),
          ],
        ),
      ),
    );
  }
}
