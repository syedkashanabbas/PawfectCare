import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class ListStoriesScreen extends StatefulWidget {
  const ListStoriesScreen({super.key});

  @override
  State<ListStoriesScreen> createState() => _ListStoriesScreenState();
}

class _ListStoriesScreenState extends State<ListStoriesScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("successStories");

  void _deleteStory(String storyId) async {
    await dbRef.child(storyId).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Story deleted")),
    );
  }

  void _editStory(String storyId, Map story) {
    final adopterCtrl = TextEditingController(text: story["adopterName"]);
    final petCtrl = TextEditingController(text: story["petName"]);
    final storyCtrl = TextEditingController(text: story["story"]);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Story"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: adopterCtrl,
                decoration: const InputDecoration(labelText: "Adopter Name"),
              ),
              TextField(
                controller: petCtrl,
                decoration: const InputDecoration(labelText: "Pet Name"),
              ),
              TextField(
                controller: storyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Story"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await dbRef.child(storyId).update({
                "adopterName": adopterCtrl.text.trim(),
                "petName": petCtrl.text.trim(),
                "story": storyCtrl.text.trim(),
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Story updated")),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text("Success Stories", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No stories yet."));
          }

          final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final stories = data.entries.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final id = stories[index].key; // Firebase push ID
              final story = Map<dynamic, dynamic>.from(stories[index].value);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: story["adopterImageUrl"] != null &&
                                    story["adopterImageUrl"].toString().isNotEmpty
                                ? NetworkImage(story["adopterImageUrl"])
                                : null,
                            radius: 24,
                            child: story["adopterImageUrl"] == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              story["adopterName"] ?? "Unknown Adopter",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editStory(id, story),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStory(id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (story["petImageUrl"] != null && story["petImageUrl"].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            story["petImageUrl"],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        "Pet: ${story["petName"] ?? "Unknown"}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(story["story"] ?? ""),
                      const SizedBox(height: 8),
                      Text(
                        "Posted on: ${story["createdAt"] ?? ""}",
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
