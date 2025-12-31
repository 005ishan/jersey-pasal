import 'package:flutter/material.dart';
import 'package:jerseypasal/core/widgets/JerseyAppBar.dart';
import 'package:jerseypasal/core/widgets/JerseyCard.dart';

class JerseyHomeScreen extends StatefulWidget {
  const JerseyHomeScreen({super.key});

  @override
  State<JerseyHomeScreen> createState() => _JerseyHomeScreenState();
}

class _JerseyHomeScreenState extends State<JerseyHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const JerseyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: const BoxDecoration(color: Color(0xFF1877F2)),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = MediaQuery.of(context).size.width >= 600;

                      return isTablet
                          ? Expanded(
                              flex: 1,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  "assets/images/neymar.png",
                                  height: 220,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/images/neymar.png",
                                width: 150,
                                height: 220,
                                fit: BoxFit.cover,
                              ),
                            );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'NEW Jerseys available',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Big',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' offers',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('SHOP NOW'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jerseys...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'New Collections',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenSansBold',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: const [
                  JerseyCard(
                    imagePath: "assets/images/realmadrid.png",
                    name: "Real Madrid",
                    price: "Rs.1,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/barcelona.png",
                    name: "Barcelona",
                    price: "Rs.3,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/arsenal.png",
                    name: "Arsenal",
                    price: "Rs.4,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/memphis.png",
                    name: "Memphis Grizzlies",
                    price: "Rs.2,000",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Football Jerseys',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenSansBold',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: const [
                  JerseyCard(
                    imagePath: "assets/images/brazil.png",
                    name: "Brazil",
                    price: "Rs.1,750",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/england.png",
                    name: "England",
                    price: "Rs.3,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/psg.png",
                    name: "PSG",
                    price: "Rs.2,999",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Basketball Jerseys',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'OpenSansBold',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                children: const [
                  JerseyCard(
                    imagePath: "assets/images/memphis.png",
                    name: "Memphis Grizzlies",
                    price: "Rs.1,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/memphis.png",
                    name: "Memphis Grizzlies",
                    price: "Rs.3,500",
                  ),
                  SizedBox(width: 16),
                  JerseyCard(
                    imagePath: "assets/images/memphis.png",
                    name: "Memphis Grizzlies",
                    price: "Rs.2,000",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
