import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';

class BlogDetailScreen extends StatefulWidget {
  const BlogDetailScreen({super.key});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  bool _isSaved = false;
  late Map<String, dynamic> blog;
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid; // current user ka uid
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    blog = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _checkIfSaved();
  }

  void _checkIfSaved() async {
    final snapshot = await FirebaseDatabase.instance
        .ref("savedBlogs/$uid/${blog['id']}")
        .get();

    setState(() {
      _isSaved = snapshot.exists;
    });
  }

  Future<void> _toggleSave() async {
    final ref = FirebaseDatabase.instance.ref("savedBlogs/$uid/${blog['id']}");

    if (_isSaved) {
      await ref.remove();
      setState(() => _isSaved = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from saved blogs")),
      );
    } else {
      await ref.set({
        "title": blog['title'],
        "description": blog['description'],
        "imageUrl": blog['imageUrl'],
        "createdAt": DateTime.now().toIso8601String(),
      });
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blog saved")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color greenColor = const Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        leading: const BackButton(color: Colors.white),
        title: const Text("Blog Detail", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _toggleSave,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Share logic with share_plus
            },
          ),
        ],
      ),
      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Blog image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: blog['imageUrl'] != null && blog['imageUrl'] != ""
                  ? Image.network(blog['imageUrl'],
                  width: double.infinity, height: 220, fit: BoxFit.cover)
                  : Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(Icons.article, size: 80, color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(blog['title'] ?? "",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            // Description
            Text(
              blog['description'] ?? "",
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 12),

            const Text("Added by Shelter Admin",
                style: TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: greenColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Manage"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
