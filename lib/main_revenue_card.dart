import 'package:flutter/material.dart';
import 'data_service.dart';

class MainRevenueCard extends StatelessWidget {
  final String revenue;
  final String comparison;
  final bool isDarkMode;

  const MainRevenueCard({
    Key? key,
    required this.revenue,
    required this.comparison,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: DataService().getBackgroundImageUrl(isDarkMode ? 7 : 5),
      builder: (context, snapshot) {
        return Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode ? const Color(0xFF383C44) : Colors.white, // Base selon le mode
            image: snapshot.hasData && snapshot.data != null
                ? DecorationImage(
                    image: NetworkImage(snapshot.data!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total Wallet Balance',
                      style: TextStyle(
                        color: const Color(0xFF222630),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      revenue,
                      style: TextStyle(
                        color: const Color(0xFF222630),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Weekly Profit',
                      style: TextStyle(
                        color: const Color(0xFF222630).withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Précédent: ${revenue.split(' ')[0]}',
                      style: TextStyle(
                        color: const Color(0xFF222630).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: comparison.contains('-') ? Colors.red : Colors.green,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comparison.contains('-') ? Icons.arrow_downward : Icons.arrow_upward,
                        color: comparison.contains('-') ? Colors.red : Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comparison,
                        style: TextStyle(
                          color: comparison.contains('-') ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}