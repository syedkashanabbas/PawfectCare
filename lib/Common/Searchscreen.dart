import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  List<Map<String, String>> _mockResults = [];

  final List<Map<String, String>> _dummyDatabase = [
    {'type': 'Pet', 'title': 'Tommy', 'subtitle': 'Golden Retriever • Age 2'},
    {'type': 'Article', 'title': 'Pet Nutrition Tips', 'subtitle': 'Published Sep 10, 2025'},
    {'type': 'Product', 'title': 'Anti-Flea Shampoo', 'subtitle': 'Pet Store Item'},
    {'type': 'Blog', 'title': 'How to Adopt a Shelter Pet', 'subtitle': 'Read Time: 4 mins'},
    {'type': 'Pet', 'title': 'Bella', 'subtitle': 'Persian Cat • Age 3'},
  ];

  void _performSearch(String query) {
    setState(() {
      _query = query;
      _mockResults = _dummyDatabase
          .where((item) => item['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: "Search pets, blogs, products...",
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_query.isEmpty)
              const Text("Start typing to search...", style: TextStyle(color: Colors.grey))
            else if (_mockResults.isEmpty)
              const Text("No results found.", style: TextStyle(color: Colors.grey))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _mockResults.length,
                  itemBuilder: (context, index) {
                    final item = _mockResults[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          item['type'] == 'Pet'
                              ? Icons.pets
                              : item['type'] == 'Article'
                              ? Icons.article
                              : item['type'] == 'Product'
                              ? Icons.shopping_bag
                              : Icons.description,
                          color: const Color(0xFF4CAF50),
                        ),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['subtitle'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate based on type (optional)
                        },
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
