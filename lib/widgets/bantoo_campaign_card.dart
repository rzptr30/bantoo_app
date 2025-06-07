import 'package:flutter/material.dart';

class BantooCampaignCard extends StatelessWidget {
  final VoidCallback onTap;
  const BantooCampaignCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AspectRatio(
              aspectRatio: 16/10, // LEBIH TINGGI DARI 16/9!
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/bantoo_hands.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: Center(
                          child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  // Overlay gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'BANTOO\nCAMPAIGN',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black38,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This programme aims to have users report to us if there are disasters, circumstances, or people who may not be publicly known and need help.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  blurRadius: 2,
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: 160,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 8,
                              ),
                              child: const Text(
                                'Bantoo!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Quote: letakkan DI LUAR Card agar tidak pernah overlap!
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
          child: Text(
            '"YOU DON\'T NEED MONEY TO HELP OTHERS, YOU JUST NEED A HEART TO HELP THEM."',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.white,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}