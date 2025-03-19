import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:html' as html; // For web-based download functionality

class VerifiedDocumentsPage extends StatefulWidget {
  const VerifiedDocumentsPage({super.key});

  @override
  _VerifiedDocumentsPageState createState() => _VerifiedDocumentsPageState();
}

class _VerifiedDocumentsPageState extends State<VerifiedDocumentsPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> documents = [];
  bool isLoading = true;
  String? userRegisterNumber;

  @override
  void initState() {
    super.initState();
    fetchUserRegisterNumber();
  }

  Future<void> fetchUserRegisterNumber() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user informations') // Collection name
          .doc(userId)
          .get();

      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception("User document not found");
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (!userData.containsKey('Register Number')) {
        throw Exception("Register number field not found");
      }

      setState(() {
        userRegisterNumber = userData['Register Number'];
      });

      fetchUploadedDocuments(userRegisterNumber!);
    } catch (e) {
      print("Error fetching register number: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUploadedDocuments(String registerNumber) async {
    try {
      // Reference to the user's folder inside 'users' in Firebase Storage
      final ListResult result = await storage.ref('users/$registerNumber').listAll();

      List<Future<Map<String, dynamic>>> documentFutures = result.items.map((ref) async {
        final FullMetadata metadata = await ref.getMetadata();
        return {
          'name': ref.name,
          'size': metadata.size,
          'url': await ref.getDownloadURL(),
        };
      }).toList();

      final docs = await Future.wait(documentFutures);

      setState(() {
        documents = docs;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load documents: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Documents'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
              ? const Center(child: Text("No documents found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(document['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Size: ${document['size']} bytes'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            try {
                              final url = document['url'];
                              // ignore: unused_local_variable
                              html.AnchorElement anchor = html.AnchorElement(href: url)
                                ..setAttribute("download", document['name'])
                                ..click();
                            } catch (e) {
                              print('Error downloading file: $e');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
