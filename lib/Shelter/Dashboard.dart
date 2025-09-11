import 'package:flutter/material.dart';

class ShelterDashboardScreen extends StatelessWidget {
  const ShelterDashboardScreen({super.key});

  final Color greenColor = const Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text("Shelter Dashboard", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard("Total Pets", "24", Icons.pets, Colors.orange),
            const SizedBox(height: 16),
            _buildStatCard("Adoption Requests", "12", Icons.assignment, Colors.blue),
            const SizedBox(height: 16),
            _buildStatCard("Approved Adoptions", "8", Icons.check_circle, Colors.green),
            const SizedBox(height: 16),
            _buildStatCard("Success Stories", "5", Icons.star, Colors.purple),
            const SizedBox(height: 24),

            // Quick Actions
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Quick Actions",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildActionButton(Icons.add_box, "Add Pet", greenColor, () {}),
                _buildActionButton(Icons.assignment, "Requests", Colors.blue, () {}),
                _buildActionButton(Icons.star, "Stories", Colors.orange, () {}),
                _buildActionButton(Icons.volunteer_activism, "Volunteers", Colors.red, () {}),
              ],
            )
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: greenColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Listings"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Stories"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
