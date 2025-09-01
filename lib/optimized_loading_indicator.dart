import 'package:flutter/material.dart';

class OptimizedLoadingIndicator extends StatefulWidget {
  final String message;
  final bool showOverlay;
  final Color? color;
  final double size;

  const OptimizedLoadingIndicator({
    super.key,
    this.message = 'Chargement en cours...',
    this.showOverlay = true,
    this.color,
    this.size = 100.0,
  });

  @override
  State<OptimizedLoadingIndicator> createState() => _OptimizedLoadingIndicatorState();
}

class _OptimizedLoadingIndicatorState extends State<OptimizedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIcon() {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.color ?? const Color(0xFFF7931A),
                    (widget.color ?? const Color(0xFFF7931A)).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? const Color(0xFFF7931A)).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sync,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showOverlay) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoadingIcon(),
            const SizedBox(height: 16),
            Text(
              widget.message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return _buildLoadingIcon();
    }
  }
}

// Version minimaliste pour les cas où on veut juste un spinner simple
class SimpleLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const SimpleLoadingSpinner({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeWidth = 2.0,
  });

  @override
  State<SimpleLoadingSpinner> createState() => _SimpleLoadingSpinnerState();
}

class _SimpleLoadingSpinnerState extends State<SimpleLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? const Color(0xFFF7931A),
        ),
        backgroundColor: (widget.color ?? const Color(0xFFF7931A)).withOpacity(0.2),
      ),
    );
  }
}

// Widget de chargement pour les cartes KPI
class KpiLoadingCard extends StatelessWidget {
  final double width;
  final double height;
  final String title;

  const KpiLoadingCard({
    super.key,
    this.width = 200,
    this.height = 160,
    this.title = 'Chargement...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SimpleLoadingSpinner(size: 32),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}