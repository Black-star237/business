import 'package:flutter/material.dart';

class OptimizedLoadingScreen extends StatefulWidget {
  const OptimizedLoadingScreen({super.key});

  @override
  State<OptimizedLoadingScreen> createState() => _OptimizedLoadingScreenState();
}

class _OptimizedLoadingScreenState extends State<OptimizedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo optimisé avec Hero animation pour transition fluide
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/logo.webp',
                            fit: BoxFit.cover,
                            // Optimisation: cache l'image
                            cacheWidth: 120,
                            cacheHeight: 120,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Titre avec animation
                    const Text(
                      'Fluxiabiz',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF7931A),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Indicateur de chargement personnalisé
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFF7931A),
                        ),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Message de chargement
                    Text(
                      'Initialisation...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}