import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_attest.dart'; // Import the attestation page

class PdfListPage extends StatefulWidget {
  const PdfListPage({super.key});

  @override
  _PdfListPageState createState() => _PdfListPageState();
}

class _PdfListPageState extends State<PdfListPage> {
  List<String> pdfUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPdfs();
  }

  Future<void> fetchPdfs() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Fetch user's position from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user informations')
          .doc(userId)
          .get();

     if (!userDoc.exists || userDoc.data() == null || !(userDoc.data() as Map<String, dynamic>).containsKey('position')) {
  throw Exception("User position not found");
}

String position = (userDoc.data() as Map<String, dynamic>)['position']; // Folder name

      final storageRef = FirebaseStorage.instance.ref().child(position);
      final result = await storageRef.listAll();

      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );

      setState(() {
        pdfUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching PDFs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pdfUrls.isEmpty
              ? const Center(child: Text('No PDFs found'))
              : ListView.builder(
                  itemCount: pdfUrls.length,
                  itemBuilder: (context, index) {
                    final pdfUrl = pdfUrls[index];
                    return ListTile(
                      title: Text('Request ${index + 1}'),
                      onTap: () {
                        // Navigate to the attestation page with the selected PDF URL
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfAttestationPage(pdfUrl: pdfUrl),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
