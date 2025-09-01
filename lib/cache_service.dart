import 'dart:convert';
import 'package:flutter/foundation.dart';

class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl = const Duration(minutes: 5);
  
  // Cache pour les données
  void setData(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTtl,
    );
  }
  
  T? getData<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().difference(entry.timestamp) > entry.ttl) {
      _cache.remove(key);
      return null;
    }
    
    return entry.data as T?;
  }
  
  // Cache spécialisé pour les KPIs
  void cacheKpis(String companyId, Map<String, dynamic> kpis) {
    setData('kpis_$companyId', kpis, ttl: const Duration(minutes: 2));
  }
  
  Map<String, dynamic>? getCachedKpis(String companyId) {
    return getData<Map<String, dynamic>>('kpis_$companyId');
  }
  
  // Cache pour les images de fond
  void cacheBackgroundImage(int assetId, String? url) {
    setData('bg_image_$assetId', url, ttl: const Duration(hours: 1));
  }
  
  String? getCachedBackgroundImage(int assetId) {
    return getData<String>('bg_image_$assetId');
  }
  
  // Cache pour les activités récentes
  void cacheRecentActivities(String companyId, List<Map<String, dynamic>> activities) {
    setData('activities_$companyId', activities, ttl: const Duration(minutes: 1));
  }
  
  List<Map<String, dynamic>>? getCachedRecentActivities(String companyId) {
    return getData<List<Map<String, dynamic>>>('activities_$companyId');
  }
  
  // Nettoyage du cache
  void clearExpired() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => 
      now.difference(entry.timestamp) > entry.ttl
    );
  }
  
  void clearAll() {
    _cache.clear();
  }
  
  // Préchargement des données critiques
  Future<void> preloadCriticalData() async {
    // Ici on peut précharger les données les plus importantes
    if (kDebugMode) {
      print('Préchargement des données critiques...');
    }
  }
}

class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });
}

// Mixin pour faciliter l'utilisation du cache dans les widgets
mixin CacheMixin {
  CacheService get cache => CacheService.instance;
  
  Future<T> withCache<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration? ttl,
  }) async {
    // Essayer de récupérer depuis le cache
    final cached = cache.getData<T>(key);
    if (cached != null) {
      return cached;
    }
    
    // Sinon, récupérer et mettre en cache
    final data = await fetcher();
    cache.setData(key, data, ttl: ttl);
    return data;
  }
}