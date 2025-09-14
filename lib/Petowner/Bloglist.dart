import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final Color greenColor = const Color(0xFF4CAF50);
  final _blogRef = FirebaseDatabase.instance.ref('blogs');
  final _savedRef = FirebaseDatabase.instance.ref('savedBlogs');
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> _blogs = [];
  List<Map<String, dynamic>> _filteredBlogs = [];
  Set<String> _savedIds = {};
  bool _isLoading = true;
  bool _showSavedOnly = false; // filter flag

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
    _fetchSaved();
  }

  void _fetchBlogs() {
    _blogRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final List<Map<String, dynamic>> fetched = [];
        data.forEach((key, value) {
          if (value is Map) {
            final blog = Map<String, dynamic>.from(value);
            blog['id'] = key;
            fetched.add(blog);
          }
        });
        setState(() {
          _blogs = fetched.reversed.toList(); // latest top
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _blogs = [];
          _filteredBlogs = [];
          _isLoading = false;
        });
      }
    });
  }

  void _fetchSaved() {
    _savedRef.child(uid).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _savedIds = data.keys.map((e) => e.toString()).toSet();
          _applyFilter();
        });
      } else {
        setState(() {
          _savedIds = {};
          _applyFilter();
        });
      }
    });
  }

  void _applyFilter() {
    if (_showSavedOnly) {
      _filteredBlogs = _blogs
          .where((b) => _savedIds.contains(b['id']))
          .toList();
    } else {
      _filteredBlogs = _blogs;
    }
  }

  void _filterBlogsByTitle(String query) {
    final base = _showSavedOnly
        ? _blogs.where((b) => _savedIds.contains(b['id'])).toList()
        : _blogs;

    if (query.isEmpty) {
      setState(() => _filteredBlogs = base);
    } else {
      setState(() {
        _filteredBlogs = base
            .where(
              (b) => (b['title'] ?? "").toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      });
    }
  }

  Future<void> _toggleSave(Map<String, dynamic> blog) async {
    final ref = _savedRef.child(uid).child(blog['id']);
    if (_savedIds.contains(blog['id'])) {
      await ref.remove();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from saved")));
    } else {
      await ref.set({
        "title": blog['title'],
        "description": blog['description'],
        "imageUrl": blog['imageUrl'],
        "createdAt": DateTime.now().toIso8601String(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Blog saved")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text(
          "Pet Care Blogs",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _showSavedOnly ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSavedOnly = !_showSavedOnly;
                _applyFilter();
              });
            },
            tooltip: _showSavedOnly ? "Show All Blogs" : "Show Saved Blogs",
          ),
        ],
      ),
      drawer: const PetOwnerDrawer(),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search blogs by title...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterBlogsByTitle,
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBlogs.isEmpty
                ? const Center(child: Text("No blogs available"))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = _filteredBlogs[index];
                      final isSaved = _savedIds.contains(blog['id']);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    blog['imageUrl'] != null &&
                                        blog['imageUrl'] != ""
                                    ? Image.network(
                                        blog['imageUrl'],
                                        width: 100,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 80,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.article,
                                          size: 40,
                                          color: Colors.green,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            blog['title'] ?? "",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isSaved
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            color: greenColor,
                                          ),
                                          onPressed: () => _toggleSave(blog),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      blog['description'] ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      "Added by Shelter Admin",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/blogdetail',
                                            arguments: blog,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: greenColor,
                                        ),
                                        child: const Text("Read More"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: greenColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: "Explore"),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Manage",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
