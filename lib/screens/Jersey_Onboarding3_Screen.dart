import 'package:flutter/material.dart';
import 'package:jerseypasal/screens/Jersey_Login_Screen.dart';

class JerseyOnboarding3Screen extends StatelessWidget {
  const JerseyOnboarding3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  'JERSEYपसल',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 20),

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/jersey7.jpg',
                            width: 300,
                            height: 800,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/jersey8.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/jersey9.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Column(
                children: [
                  Text(
                    "PREMIUM QUALITY",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We deliver premium, durable, and customer-approved jerseys.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JerseyLoginScreen(),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Get Started', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
