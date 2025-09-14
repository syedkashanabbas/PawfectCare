import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class ShelterBlogListScreen extends StatefulWidget {
  const ShelterBlogListScreen({super.key});

  @override
  State<ShelterBlogListScreen> createState() => _ShelterBlogListScreenState();
}

class _ShelterBlogListScreenState extends State<ShelterBlogListScreen> {
  final _blogRef = FirebaseDatabase.instance.ref('blogs');
  List<Map<String, dynamic>> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  void _fetchBlogs() {
    _blogRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final List<Map<String, dynamic>> fetched = [];
        data.forEach((key, value) {
          if (value is Map) {
            final map = Map<String, dynamic>.from(value);
            map['id'] = key;
            fetched.add(map);
          }
        });
        setState(() {
          _blogs = fetched.reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _blogs = [];
          _isLoading = false;
        });
      }
    });
  }

  void _showBlogForm({Map<String, dynamic>? blog}) {
    final titleCtrl = TextEditingController(text: blog?['title'] ?? "");
    final descCtrl = TextEditingController(text: blog?['description'] ?? "");

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(blog == null ? "Add Blog" : "Edit Blog"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Title")),
                TextField(controller: descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: "Description")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final payload = {
                  "title": titleCtrl.text,
                  "description": descCtrl.text,
                  "imageUrl": blog?['imageUrl'] ?? "",
                  "createdAt": DateTime.now().toIso8601String(),
                };

                if (blog == null) {
                  await _blogRef.push().set(payload);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Blog added")));
                } else {
                  await _blogRef.child(blog['id']).update(payload);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Blog updated")));
                }
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showBlogView(Map<String, dynamic> blog) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(blog['title'] ?? "Blog"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog['imageUrl'] != null && blog['imageUrl'] != "")
                  Image.network(blog['imageUrl'], height: 200, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text(blog['description'] ?? ""),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
          ],
        );
      },
    );
  }

  void _deleteBlog(Map<String, dynamic> blog) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Blog"),
        content: const Text("Are you sure you want to delete this blog?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // pehle UI update kar lo
      setState(() {
        _blogs.removeWhere((b) => b['id'] == blog['id']);
      });

      await _blogRef.child(blog['id']).remove();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Blog deleted")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Blogs', style: TextStyle(color: Colors.white),),
      ),
      drawer: const ShelterDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () => _showBlogForm(),
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blogs.isEmpty
          ? const Center(child: Text("No blogs available"))
          : ListView.builder(
        itemCount: _blogs.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final b = _blogs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: b['imageUrl'] != null && b['imageUrl'] != ""
                  ? Image.network(b['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.article, color: Colors.green),
              title: Text(b['title'] ?? ""),
              subtitle: Text(
                b['description'] != null && b['description'].toString().length > 50
                    ? "${b['description'].toString().substring(0, 50)}..."
                    : b['description'] ?? "",
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "view") {
                    _showBlogView(b);
                  } else if (value == "edit") {
                    _showBlogForm(blog: b);
                  } else if (value == "delete") {
                    _deleteBlog(b);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: "view", child: Text("View")),
                  const PopupMenuItem(value: "edit", child: Text("Edit")),
                  const PopupMenuItem(
                    value: "delete",
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
