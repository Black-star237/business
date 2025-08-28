 import 'package:flutter/material.dart';
import '../models/product.dart';
import 'dart:ui';

class ProductsPage extends StatelessWidget {
  final List<Product> products;
  const ProductsPage({required this.products});

  @override
  Widget build(BuildContext context) {
    // Produits fictifs pour un meilleur aperçu
    final List<Product> demoProducts = [
      Product(
        id: '1',
        companyId: 'company1',
        name: 'iPhone 15 Pro',
        description: 'Smartphone Apple dernière génération',
        price: 1299.99,
        stock: 25,
        imageUrl: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400',
      ),
      Product(
        id: '2',
        companyId: 'company1',
        name: 'MacBook Air M2',
        description: 'Ordinateur portable Apple',
        price: 1499.99,
        stock: 12,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      ),
      Product(
        id: '3',
        companyId: 'company1',
        name: 'AirPods Pro',
        description: 'Écouteurs sans fil Apple',
        price: 249.99,
        stock: 45,
        imageUrl: 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400',
      ),
      Product(
        id: '4',
        companyId: 'company1',
        name: 'iPad Air',
        description: 'Tablette Apple polyvalente',
        price: 699.99,
        stock: 18,
        imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
      ),
      Product(
        id: '5',
        companyId: 'company1',
        name: 'Apple Watch Series 9',
        description: 'Montre connectée Apple',
        price: 399.99,
        stock: 32,
        imageUrl: 'https://images.unsplash.com/photo-1434493789847-2f02dc6ca35d?w=400',
      ),
      Product(
        id: '6',
        companyId: 'company1',
        name: 'iMac 24"',
        description: 'Ordinateur tout-en-un Apple',
        price: 1499.99,
        stock: 8,
        imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
      ),
      Product(
        id: '7',
        companyId: 'company1',
        name: 'HomePod mini',
        description: 'Enceinte intelligente Apple',
        price: 99.99,
        stock: 15,
        imageUrl: 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=400',
      ),
      Product(
        id: '8',
        companyId: 'company1',
        name: 'Magic Keyboard',
        description: 'Clavier sans fil Apple',
        price: 99.99,
        stock: 22,
        imageUrl: 'https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=400',
      ),
    ];

    return Stack(
      children: [
        // Fond d'écran + flou
        Positioned.fill(
          child: Image.asset(
            'assets/logos/f.png',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        // Layout principal
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header compact
                        _CompactHeader(),
                        const SizedBox(height: 24),
                        // Grille de produits
                        Expanded(
                          child: _ProductsGrid(products: demoProducts),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Sidebar droite
                  _RightSidebar(products: demoProducts),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Header compact ---
class _CompactHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Products',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Spacer(),
        // Bouton d'ajout
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// --- Grille de produits ---
class _ProductsGrid extends StatelessWidget {
  final List<Product> products;
  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _ProductCard(product: products[index]);
      },
    );
  }
}

// --- Carte produit améliorée ---
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Informations du produit
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et prix
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(0)}€',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Stock et actions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: product.stock < 10 ? Colors.redAccent.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Stock: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stock < 10 ? Colors.redAccent : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Actions
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 16, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Sidebar droite ---
class _RightSidebar extends StatelessWidget {
  final List<Product> products;
  const _RightSidebar({required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            
            // Recherche
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Catégories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _CategoryFilter(label: 'All Products', selected: true),
            _CategoryFilter(label: 'Électronique', selected: false),
            _CategoryFilter(label: 'Alimentaire', selected: false),
            _CategoryFilter(label: 'Textile', selected: false),
            _CategoryFilter(label: 'Autres', selected: false),
            const SizedBox(height: 20),
            
            // Stock
            const Text(
              'Stock Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _StockFilter(label: 'In Stock', selected: true),
            _StockFilter(label: 'Low Stock', selected: false),
            _StockFilter(label: 'Out of Stock', selected: false),
            const SizedBox(height: 20),
            
            // Statistiques
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _StatCard(
              title: 'Total Products',
              value: '${products.length}',
              icon: Icons.inventory,
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _StatCard(
              title: 'Low Stock',
              value: '${products.where((p) => p.stock < 10).length}',
              icon: Icons.warning,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _StatCard(
              title: 'Total Value',
              value: '${(products.fold(0.0, (sum, p) => sum + (p.price * p.stock)) / 1000).toStringAsFixed(1)}k€',
              icon: Icons.euro,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Filtre de catégorie ---
class _CategoryFilter extends StatelessWidget {
  final String label;
  final bool selected;
  const _CategoryFilter({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: selected ? Colors.deepPurple : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.deepPurple : Colors.black87,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Filtre de stock ---
class _StockFilter extends StatelessWidget {
  final String label;
  final bool selected;
  const _StockFilter({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.deepPurple.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? Colors.deepPurple : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.deepPurple : Colors.black87,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Carte de statistique ---
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}