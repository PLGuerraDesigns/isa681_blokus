import 'package:blokus/widgets/gmu_blokus_background.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.waitForSplashScreen});
  final Function() waitForSplashScreen;

  @override
  Widget build(BuildContext context) {
    waitForSplashScreen();
    return Scaffold(
        body: GMUBlokusBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'BLOKUS',
            style: TextStyle(
                fontFamily: 'LemonMilk', fontSize: 70, color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'By\nCharlie Tucker\n& Pablo L. Guerra',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 25,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'GMU ISA 681 - Spring 2023',
            style: TextStyle(
              fontFamily: 'LemonMilk',
              fontSize: 20,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ));
  }
}
