import 'package:flutter/material.dart';
import 'cache_service.dart';

class OptimizedImageWidget extends StatefulWidget {
  final String? networkUrl;
  final String fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool applyBlur;
  final int? cacheId;

  const OptimizedImageWidget({
    super.key,
    this.networkUrl,
    required this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.applyBlur = false,
    this.cacheId,
  });

  @override
  State<OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<OptimizedImageWidget> {
  String? _cachedUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    // Vérifier le cache d'abord
    if (widget.cacheId != null) {
      _cachedUrl = CacheService.instance.getCachedBackgroundImage(widget.cacheId!);
      if (_cachedUrl != null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Si pas de cache, utiliser l'URL fournie
    if (widget.networkUrl != null) {
      _cachedUrl = widget.networkUrl;
      
      // Mettre en cache si on a un ID
      if (widget.cacheId != null) {
        CacheService.instance.cacheBackgroundImage(widget.cacheId!, widget.networkUrl);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildImage() {
    Widget imageWidget;

    if (_hasError || _cachedUrl == null) {
      // Utiliser l'image de fallback
      imageWidget = Image.asset(
        widget.fallbackAsset,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
            ),
          );
        },
      );
    } else {
      // Utiliser l'image réseau avec fallback
      imageWidget = Image.network(
        _cachedUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          
          // Afficher l'image de fallback pendant le chargement
          return Image.asset(
            widget.fallbackAsset,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            cacheWidth: widget.width?.toInt(),
            cacheHeight: widget.height?.toInt(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // En cas d'erreur, utiliser l'image de fallback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          });
          
          return Image.asset(
            widget.fallbackAsset,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            cacheWidth: widget.width?.toInt(),
            cacheHeight: widget.height?.toInt(),
          );
        },
      );
    }

    // Appliquer le flou si demandé
    if (widget.applyBlur) {
      return ImageFiltered(
        imageFilter: const ColorFilter.mode(
          Colors.transparent,
          BlendMode.multiply,
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Afficher immédiatement l'image de fallback pendant le chargement
      return Image.asset(
        widget.fallbackAsset,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        cacheWidth: widget.width?.toInt(),
        cacheHeight: widget.height?.toInt(),
      );
    }

    return _buildImage();
  }
}

// Widget spécialisé pour les arrière-plans avec flou
class OptimizedBackgroundImage extends StatelessWidget {
  final String? networkUrl;
  final String fallbackAsset;
  final int? cacheId;
  final Widget child;

  const OptimizedBackgroundImage({
    super.key,
    this.networkUrl,
    required this.fallbackAsset,
    this.cacheId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        OptimizedImageWidget(
          networkUrl: networkUrl,
          fallbackAsset: fallbackAsset,
          fit: BoxFit.cover,
          cacheId: cacheId,
        ),
        // Overlay sombre pour améliorer la lisibilité
        Container(
          color: Colors.black.withOpacity(0.4),
        ),
        child,
      ],
    );
  }
}