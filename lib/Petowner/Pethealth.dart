import 'package:flutter/material.dart';


class PetHealthScreen extends StatelessWidget {
  const PetHealthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final greenColor = Color(0xFF4CAF50);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenColor,
        title: const Text('Pet Health'),
        leading: BackButton(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: greenColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Text("Wellness", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Medical Records", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Vaccinations
            _sectionCard(
              title: "Vaccinations",
              onSeeAll: () {},
              children: [
                _infoTile("Rabies vaccination", "24th Jan 2022", "Dr. Nambuvan"),
                _infoTile("Calicivirus", "12th Feb 2022", "Dr. Raam"),
              ],
            ),

            const SizedBox(height: 20),

            // Allergies
            _sectionCard(
              title: "Allergies",
              onSeeAll: () {},
              children: [
                _infoTile("Skin Allergies", "May be accompanied by gastrointestinal symptoms.", "Dr. Jerry"),
                _infoTile("Food Allergies", "Vomiting and diarrhea or dermatologic signs.", "Dr. Klein"),
              ],
            ),

            const SizedBox(height: 20),

            // Appointments
            _appointmentCard(context),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _sectionCard({
    required String title,
    required VoidCallback onSeeAll,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text("See all", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String subtitle, String doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subtitle),
        Text(doctor, style: const TextStyle(color: Colors.grey)),
        const Divider(),
      ],
    );
  }

  Widget _appointmentCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Appointments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text("When you schedule an appointment, you’ll see it here. Let’s set your first appointment."),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      currentIndex: 4, // Profile
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Manage'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
