import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/Jersey_Onboarding2_Screen.dart';

class JerseyOnboarding1Screen extends StatelessWidget {
  const JerseyOnboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text(
                  'JERSEYपसल',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Image Grid
              Expanded(
                child: Row(
                  children: [
                    // Left Big Image
                    Expanded(
                      child: _imageCard('assets/images/jersey1.jpg'),
                    ),
                    const SizedBox(width: 10),
                    // Right Two Stacked Images
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: _imageCard('assets/images/jersey2.jpg'),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _imageCard('assets/images/jersey3.jpg'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Welcome Text
              const Center(
                child: Column(
                  children: [
                    Text(
                      "WELCOME TO JERSEYPASAL",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Your one-stop destination for premium and authentic jerseys.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Next Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JerseyOnboarding2Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Next',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for image cards
  Widget _imageCard(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
