import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectcare/auth_service.dart';

class StoreDrawer extends StatelessWidget {
  final String role;

  const StoreDrawer({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFE8F5E9),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.store, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Ecommerce Store",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),

          // ✅ Dashboard (role-based navigation)
          _buildItem(context, Icons.dashboard, 'Dashboard', '/dashboard'),

          // Common screens (sab roles ke liye)
          _buildItem(context, Icons.list, 'Product List', '/storelist'),
          _buildItem(context, Icons.shopping_cart, 'Cart', '/cart'),
          _buildItem(context, Icons.favorite, 'Wishlist', '/storewishlist'),

          // Sirf Super Admin ko ye 3 show honge
          if (role == "Super Admin") ...[
            _buildItem(context, Icons.add_box, 'Add Product', '/addproduct'),
            _buildItem(context, Icons.list_alt, 'Orders List', '/orderslist'),
            _buildItem(context, Icons.edit, 'Edit Product', '/editproduct'),
          ],

          const Divider(),

          // ✅ Logout
          _buildItem(
            context,
            Icons.logout,
            'Logout',
            '/login',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, "/login");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: onTap ??
          () {
            if (route == "/dashboard") {
              // Role-based navigation
              if (context.mounted) {
                if (role == "Super Admin") {
                  Navigator.pushReplacementNamed(
                      context, "/shelterdashboard");
                } else if (role == "Veterinarian") {
                  Navigator.pushReplacementNamed(context, "/vetdashboard");
                } else if (role == "Pet Owner") {
                  Navigator.pushReplacementNamed(
                      context, "/petownerdashboard");
                } else {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              }
            } else {
              Navigator.of(context).pushNamed(route);
            }
          },
    );
  }
}
