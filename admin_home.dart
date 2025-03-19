import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project2/admin_certificate_attest.dart';
import 'package:project2/admin_menu.dart'; // Assuming you have this in your project
import 'package:project2/req_list_page.dart';
import 'package:project2/eve_upload.dart';

class admin_home extends StatelessWidget {
  const admin_home({super.key});

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

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String? userPosition;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('user informations').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          userPosition = userDoc['position'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 248, 250, 234),
              Color.fromARGB(255, 246, 249, 226),
              Color.fromARGB(255, 246, 249, 227),
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
                    Column(
                      children: [
                        if (userPosition == 'principal') // Conditionally show the button
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1,
                          height: 100,
                          child: menuButton(context, 'EVENT NOTIFICATION', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DocumentUploadPage()),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1,
                          height: 100,
                          child: menuButton(context, 'REQUESTES', () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PdfListPage()),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        if (userPosition == 'principal') // Conditionally show the button
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 100,
                            child: menuButton(context, 'CERTIFICATE REQUEST', () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CertificateListPage()),
                              );
                            }),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
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
        backgroundColor: Colors.white.withOpacity(0.3),
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