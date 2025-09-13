import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'None';

  final _searchController = TextEditingController();

  void _filterAndSort() {
    List<Map<String, dynamic>> filtered = _allProducts.where((product) {
      final name = product['name']?.toString().toLowerCase() ?? '';
      final category = product['category'] ?? '';
      return name.contains(_searchQuery.toLowerCase()) &&
          (_selectedCategory == 'All' || category == _selectedCategory);
    }).toList();

    if (_sortBy == 'Price Low to High') {
      filtered.sort((a, b) => (a['price'] ?? 0).compareTo(b['price'] ?? 0));
    } else if (_sortBy == 'Price High to Low') {
      filtered.sort((a, b) => (b['price'] ?? 0).compareTo(a['price'] ?? 0));
    } else if (_sortBy == 'Name') {
      filtered.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().child("products").onValue.listen((event) {
      if (event.snapshot.value != null) {
        final productsMap = Map<String, dynamic>.from(event.snapshot.value as Map);
        final productsList = productsMap.entries.map((e) {
          final val = Map<String, dynamic>.from(e.value);
          val['id'] = e.key;
          return val;
        }).toList();

        setState(() {
          _allProducts = productsList;
        });
        _filterAndSort();
      }
    });

    _searchController.addListener(() {
      _searchQuery = _searchController.text;
      _filterAndSort();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _getCategories() {
    final categories = _allProducts.map((e) => e['category']?.toString() ?? '').toSet().toList();
    categories.removeWhere((e) => e.isEmpty);
    return ['All', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('All Products', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _getCategories().map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategory = val!);
                      _filterAndSort();
                    },
                    decoration: InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sortBy,
                    items: ['None', 'Price Low to High', 'Price High to Low', 'Name'].map((sort) {
                      return DropdownMenuItem(value: sort, child: Text(sort));
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _sortBy = val!);
                      _filterAndSort();
                    },
                    decoration: InputDecoration(
                      labelText: 'Sort By',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text("No products found."))
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _productCard(context, product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              product['image'] ?? '',
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 120),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product['price']?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/storedetail', arguments: product['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View', style: TextStyle(color: Colors.white)),
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
