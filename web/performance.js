// Configuration d'optimisation des performances pour la PWA Flutter
(function() {
  'use strict';

  // Préchargement des ressources critiques
  function preloadCriticalResources() {
    const criticalAssets = [
      'assets/logo.webp',
      'assets/1238.webp',
      'assets/welcom.webp'
    ];

    criticalAssets.forEach(asset => {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'image';
      link.href = asset;
      document.head.appendChild(link);
    });
  }

  // Optimisation du chargement des polices
  function optimizeFontLoading() {
    const fontLink = document.createElement('link');
    fontLink.rel = 'preload';
    fontLink.as = 'font';
    fontLink.type = 'font/ttf';
    fontLink.href = 'assets/fonts/Roboto-Regular.ttf';
    fontLink.crossOrigin = 'anonymous';
    document.head.appendChild(fontLink);
  }

  // Cache des ressources statiques
  function setupResourceCache() {
    if ('caches' in window) {
      const CACHE_NAME = 'fluxiabiz-v1';
      const urlsToCache = [
        '/',
        '/main.dart.js',
        '/assets/logo.webp',
        '/assets/1238.webp',
        '/assets/welcom.webp',
        '/assets/fonts/Roboto-Regular.ttf',
        '/assets/fonts/Roboto-Bold.ttf'
      ];

      caches.open(CACHE_NAME)
        .then(cache => {
          return cache.addAll(urlsToCache);
        })
        .catch(error => {
          console.log('Erreur de mise en cache:', error);
        });
    }
  }

  // Optimisation des images
  function optimizeImages() {
    // Lazy loading pour les images non critiques
    if ('IntersectionObserver' in window) {
      const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.classList.remove('lazy');
            imageObserver.unobserve(img);
          }
        });
      });

      document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
      });
    }
  }

  // Optimisation de la connexion réseau
  function optimizeNetworkRequests() {
    // Préconnexion aux domaines externes
    const domains = [
      'https://hhkqazdivfkqcpcjdqbv.supabase.co'
    ];

    domains.forEach(domain => {
      const link = document.createElement('link');
      link.rel = 'preconnect';
      link.href = domain;
      document.head.appendChild(link);
    });
  }

  // Gestion de l'état de la connexion
  function handleConnectionState() {
    if ('connection' in navigator) {
      const connection = navigator.connection;
      
      // Adapter la qualité selon la connexion
      if (connection.effectiveType === 'slow-2g' || connection.effectiveType === '2g') {
        document.body.classList.add('low-bandwidth');
      }

      // Écouter les changements de connexion
      connection.addEventListener('change', () => {
        if (connection.effectiveType === 'slow-2g' || connection.effectiveType === '2g') {
          document.body.classList.add('low-bandwidth');
        } else {
          document.body.classList.remove('low-bandwidth');
        }
      });
    }
  }

  // Optimisation du rendu
  function optimizeRendering() {
    // Utiliser requestIdleCallback pour les tâches non critiques
    if ('requestIdleCallback' in window) {
      requestIdleCallback(() => {
        setupResourceCache();
        optimizeImages();
      });
    } else {
      // Fallback pour les navigateurs qui ne supportent pas requestIdleCallback
      setTimeout(() => {
        setupResourceCache();
        optimizeImages();
      }, 100);
    }
  }

  // Métriques de performance
  function trackPerformanceMetrics() {
    if ('performance' in window) {
      window.addEventListener('load', () => {
        setTimeout(() => {
          const perfData = performance.getEntriesByType('navigation')[0];
          const loadTime = perfData.loadEventEnd - perfData.fetchStart;
          
          console.log('Temps de chargement total:', loadTime + 'ms');
          
          // Envoyer les métriques à un service d'analytics si nécessaire
          if (loadTime > 3000) {
            console.warn('Temps de chargement lent détecté:', loadTime + 'ms');
          }
        }, 0);
      });
    }
  }

  // Initialisation des optimisations
  function initializeOptimizations() {
    preloadCriticalResources();
    optimizeFontLoading();
    optimizeNetworkRequests();
    handleConnectionState();
    optimizeRendering();
    trackPerformanceMetrics();
  }

  // Démarrer les optimisations dès que possible
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeOptimizations);
  } else {
    initializeOptimizations();
  }

})();