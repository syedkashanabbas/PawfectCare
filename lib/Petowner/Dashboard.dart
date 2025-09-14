import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pawfectcare/Petowner/PetOwnerDrawer.dart';
import 'package:pawfectcare/auth_service.dart';
import 'package:pawfectcare/Petowner/Add_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetOwnerDashboard extends StatelessWidget {
  const PetOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                "Hey...",
                style: TextStyle(color: Colors.white),
              );
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                "Hey User,",
                style: TextStyle(color: Colors.white),
              );
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final name = data["name"] ?? "User";
            return Text(
              "Hey $name,",
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        actions: [
          // notification stream...
          // logout button...
        ],
      ),


      drawer: const PetOwnerDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _myPetsSection(userId),
            const SizedBox(height: 16),
            _appointmentsSection(context),
            const SizedBox(height: 16),
            _petFoodSection(),
            const SizedBox(height: 16),
            _blogTipsSection(context),
            const SizedBox(height: 16),
            _vetsSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'My Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // ================== MY PETS ==================
  Widget _myPetsSection(String? userId) {
    final dbRef = FirebaseDatabase.instance.ref("pets");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Pets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: StreamBuilder(
            stream: dbRef.orderByChild("ownerId").equalTo(userId).onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return Row(children: [_addPetButton(context)]);
              }

              final petsMap = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );

              final pets = petsMap.entries.toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length + 1,
                itemBuilder: (context, index) {
                  if (index == pets.length) return _addPetButton(context);

                  final pet = Map<String, dynamic>.from(pets[index].value);
                  final petId = pets[index].key;
                  return _petAvatar(
                    context,
                    petId,
                    pet['name'] ?? "Pet",
                    pet['imageUrl'] ?? "",
                  ).paddingSymmetric(horizontal: 10);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _petAvatar(BuildContext context, String petId, String name, String imageUrl) {
    final dbRef = FirebaseDatabase.instance.ref("pets");

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.pets, size: 28, color: Colors.grey)
                  : null,
            ),
            Positioned(
              right: -4,
              top: -4,
              child: PopupMenuButton<String>(
                onSelected: (val) async {
                  if (val == "delete") {
                    await dbRef.child(petId).remove();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pet deleted")),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "delete", child: Text("Delete")),
                ],
                icon: const Icon(Icons.more_vert, size: 18),
              ),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(name),
      ],
    );
  }

  Widget _addPetButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPetProfileScreen()),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.add, color: Colors.green[700]),
          ),
          const SizedBox(height: 4),
          const Text("Add"),
        ],
      ),
    ).paddingSymmetric(horizontal: 10);
  }

  Widget _appointmentsSection(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/appointment");
      },
      child: _infoCard(Icons.calendar_today, 'Appointments', 'Upcoming & Past'),
    );
  }

  Widget _infoCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.green[700]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _petFoodSection() {
    final dbRef = FirebaseDatabase.instance.ref("products");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pet Food',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: StreamBuilder(
            stream: dbRef.orderByChild("category").equalTo("food").onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(child: Text("No food products available"));
              }

              final productsMap = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map,
              );

              final products = productsMap.entries.toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = Map<String, dynamic>.from(products[index].value);
                  final title = product["name"] ?? "Unnamed";
                  final imageUrl = product["image"] ?? "";
                  return _productCard(title, imageUrl);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _productCard(String title, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Image.network(imageUrl, height: 70, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }

  Widget _blogTipsSection(BuildContext context) => GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/bloglist');
    },
    child: _infoCard(
      Icons.article,
      'Pet Care Tips',
      'Nutrition, Training, First Aid',
    ),
  );

  // ================== VETS SECTION ==================
  Widget _vetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where("role", isEqualTo: "Veterinarian")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("No vets available");
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = data["name"] ?? "Vet";
                final imageUrl = data["profileImage"] ?? "";
                return _vetCard(name: name, imageUrl: imageUrl);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _vetCard({required String name, required String imageUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
            imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            radius: 30,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}

extension WidgetPaddingX on Widget {
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
