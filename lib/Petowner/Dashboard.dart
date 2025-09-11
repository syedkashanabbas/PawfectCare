import 'package:flutter/material.dart';
import 'package:pawfectcare/auth_service.dart';

class PetOwnerDashboard extends StatelessWidget {
  const PetOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[600],
        elevation: 0,
        title: const Text('Hey Pixel Posse,'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await AuthService().logoutUser(); // sign out from Firebase
              Navigator.pushReplacementNamed(
                context,
                "/login",
              ); // go back to login screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _myPetsSection(),
            const SizedBox(height: 16),
            _locationAndStatusSection(),
            const SizedBox(height: 16),
            _healthReminderSection(),
            const SizedBox(height: 16),
            _appointmentsSection(),
            const SizedBox(height: 16),
            _petFoodSection(),
            const SizedBox(height: 16),
            _blogTipsSection(),
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

  Widget _myPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Pets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _petAvatar('Bello', 'https://i.imgur.com/1.jpg'),
              _petAvatar('Rowdy', 'https://i.imgur.com/2.jpg'),
              _petAvatar('Furry', 'https://i.imgur.com/3.jpg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _petAvatar(String name, String imageUrl) {
    return Column(
      children: [
        CircleAvatar(radius: 28, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(height: 4),
        Text(name),
      ],
    ).paddingSymmetric(horizontal: 10);
  }

  Widget _locationAndStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoCard(Icons.location_on, 'Pet Location', 'Track Pets'),
        _infoCard(Icons.health_and_safety, 'Pet Status', 'Check Vitals'),
      ],
    );
  }

  Widget _healthReminderSection() {
    return _infoCard(Icons.vaccines, 'Health Reminders', 'Vaccines, Deworming');
  }

  Widget _appointmentsSection() {
    return _infoCard(Icons.calendar_today, 'Appointments', 'Upcoming & Past');
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
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _productCard('Josera Active Dog', 'https://i.imgur.com/x1.png'),
              _productCard('Happy Dog Food', 'https://i.imgur.com/x2.png'),
            ],
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

  Widget _blogTipsSection() {
    return _infoCard(
      Icons.article,
      'Pet Care Tips',
      'Nutrition, Training, First Aid',
    );
  }

  Widget _vetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vets',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _vetCard(
          name: 'Dr. Nambuvan',
          imageUrl: 'https://i.imgur.com/dr.jpg',
          lastVisit: '25/11/2022',
        ),
      ],
    );
  }

  Widget _vetCard({
    required String name,
    required String imageUrl,
    required String lastVisit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(imageUrl), radius: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('⭐ 5.0 (100 reviews)'),
                Text('Last Visit: $lastVisit'),
              ],
            ),
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
