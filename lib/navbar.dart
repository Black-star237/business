import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, 'Accueil'),
          _buildNavItem(Icons.inventory, 1, 'Produits'),
          _buildNavItem(Icons.add, 2, 'Ajouter', isMainButton: true),
          _buildNavItem(Icons.receipt, 3, 'Factures'),
          _buildNavItem(Icons.people, 4, 'Clients'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label, {bool isMainButton = false}) {
    final isActive = currentIndex == index;
    final iconColor = isActive ? Colors.black : Colors.white;
    final iconSize = isMainButton ? 36.0 : 24.0;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            )
          else
            Icon(
              icon,
              color: iconColor,
              size: iconSize,
            ),
          const SizedBox(height: 4),
          // Text(
          //   label,
          //   style: TextStyle(
          //     color: isActive ? Colors.black : Colors.white,
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }
}