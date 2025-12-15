import 'package:flutter/material.dart';

class JerseyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onCartTap;

  const JerseyAppBar({super.key, this.onCartTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,

      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: double.infinity,
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome 👋',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                      Text(
                        'Customer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  IconButton(
                    onPressed: onCartTap,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
