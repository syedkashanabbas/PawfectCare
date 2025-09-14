import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawfectcare/Shelter/ShelterDrawer.dart';

class PetListingScreen extends StatelessWidget {
  const PetListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance.ref("pets");

    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Text('All Pets', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const ShelterDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () {
          Navigator.pushNamed(context, '/add_editlisting');
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder(
          stream: dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return const Center(child: Text("No pets found"));
            }

            final petsMap = Map<dynamic, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final pets = petsMap.entries.map((e) {
              final pet = Map<String, dynamic>.from(e.value);
              pet["id"] = e.key; // push key
              return pet;
            }).toList();

            return GridView.builder(
              itemCount: pets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _petCard(pet, dbRef, context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _petCard(Map<String, dynamic> pet, DatabaseReference dbRef, BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(pet["ownerId"])
          .get(),
      builder: (context, userSnap) {
        String ownerName = "Unknown User";
        if (userSnap.hasData && userSnap.data!.exists) {
          final userData = userSnap.data!.data() as Map<String, dynamic>;
          ownerName = userData["name"] ?? "No Name";
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // kebab menu at top-right
              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == "view") {
                      // TODO: Navigate to pet details
                    } else if (value == "delete") {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Pet"),
                          content: const Text("Are you sure you want to delete this pet?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await dbRef.child(pet["id"]).remove();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pet deleted")),
                        );
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: "view", child: Text("View Details")),
                    const PopupMenuItem(
                      value: "delete",
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),

              CircleAvatar(
                radius: 40,
                backgroundImage: pet['imageUrl'] != null && pet['imageUrl'] != ""
                    ? NetworkImage(pet['imageUrl'])
                    : null,
                child: (pet['imageUrl'] == null || pet['imageUrl'] == "")
                    ? const Icon(Icons.pets, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                pet['name'] ?? "Pet",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "${pet['species']} • ${pet['breed']}",
                style: const TextStyle(fontSize: 12),
              ),
              Text("${pet['age']}", style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                "Owner: $ownerName",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
