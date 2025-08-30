import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;
  final bool showOverlay;

  const LoadingIndicator({
    super.key,
    this.message = 'Chargement en cours...',
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showOverlay) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/chargement_voiture_lottie.json',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else {
      return Lottie.asset(
        'assets/chargement_voiture_lottie.json',
        width: 100,
        height: 100,
        fit: BoxFit.contain,
      );
    }
  }
}