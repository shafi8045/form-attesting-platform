import 'package:flutter/material.dart';
import 'package:project2/main.dart';
import 'package:project2/admin_profile.dart';
import 'package:project2/req_list_page.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color.fromARGB(255, 193, 193, 193), // AppBar color matching the gradient theme
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 189, 189, 189), // Purple gradient color
              Color.fromARGB(255, 194, 194, 194), // Darker purple color
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Menu Item
              menuItem(context, 'Profile', Icons.person),
              const SizedBox(height: 20),
              // Requests Menu Item
              menuItem(context, 'Requests', Icons.request_page),
              const SizedBox(height: 20),
              // Pending Menu Item
              menuItem(context, 'Pending', Icons.pending_actions),
              const SizedBox(height: 20),
              // Logout Menu Item
              menuItem(context, 'Logout', Icons.logout),
            ],
          ),
        ),
      ),
    );
  }

  // A helper function to create menu items with consistent styling
  Widget menuItem(BuildContext context, String title, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        // Handle button action
        switch (title) {
          case 'Profile':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
          case 'Verified':
            
            break;
          case 'Pending':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PdfListPage()),
            );
            break;
          case 'Logout':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
            // Handle Logout action
            break;
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.white.withOpacity(0.3), // Transparent button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
