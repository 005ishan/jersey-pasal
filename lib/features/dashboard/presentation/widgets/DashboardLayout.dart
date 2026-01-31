import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/Jersey_Cart_Screen.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/Jersey_Home_Screen.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/Jersey_Profile_Screen.dart';
import 'package:jerseypasal/features/dashboard/presentation/pages/Jersey_Wishlist_Screen.dart';

class DashboardLayout extends StatefulWidget {
  final int initialIndex;

  const DashboardLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  late int _selectedIndex;

  final List<Widget> _screens = const [
    JerseyHomeScreen(),
    JerseyWishlistScreen(),
    JerseyCartScreen(),
    JerseyProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: const Color(0xFF1877F2),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: GNav(
          backgroundColor: const Color(0xFF1877F2),
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
