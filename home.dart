import 'package:flutter/material.dart';
import 'package:project2/certificate_req.dart';
import 'package:project2/menu.dart'; // Assuming you have this in your project
import 'package:project2/notification.dart'; // Import the documents.dart file
import 'package:project2/request.dart';
import 'package:project2/hostel.dart';
import 'package:project2/verified_req.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Menu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 213, 220, 165)),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 248, 250, 234), // Purple gradient color
              Color.fromARGB(255, 246, 249, 226),
              Color.fromARGB(255, 246, 249, 227), // Red gradient color
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar with Menu Icon and Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu Icon
                    IconButton(
                      icon: const Icon(Icons.menu, color: Color.fromARGB(255, 45, 38, 38)),
                      onPressed: () {
                        // Handle menu action
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MenuScreen()),
                        );
                      },
                    ),
                    // Search Bar
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 53, 44, 44).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: Color.fromARGB(255, 61, 51, 51)),
                            hintText: 'Search',
                            hintStyle: TextStyle(color: Color.fromARGB(137, 57, 47, 47)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Buttons List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Notifications Button (now goes to DocumentsScreen)
                   Column(
  children: [
    SizedBox(
      width: MediaQuery.of(context).size.width * 1, // Adjust width as needed
      height: 100, // Adjust height as needed
      child: menuButton(context, 'NOTIFICATIONS', () { 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadedDocumentsPage()),
        );
      }),
    ),
    const SizedBox(height: 20),

    SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      height: 100,
      child: menuButton(context, 'CERTIFICATE', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CertificatePage()),
        );
      }),
    ),
    const SizedBox(height: 20),

    SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      height: 100,
      child: menuButton(context, 'COMPLAINTS', () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => FormPage()),
         );
      }),
      
    ),
    const SizedBox(height: 20),

    SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      height: 100,
      child: menuButton(context, 'HOSTEL', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FormPage1()),
        );
      }),
    ),
    const SizedBox(height: 20),

    SizedBox(
      width: MediaQuery.of(context).size.width * 1,
      height: 100,
      child: menuButton(context, 'VERIFIED', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifiedDocumentsPage()),
        );
      }),
    ),
    const SizedBox(height: 20),
  ],
)

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper function to create menu buttons with a consistent style and action
  Widget menuButton(BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: Colors.white.withOpacity(0.3), // Transparent button
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
