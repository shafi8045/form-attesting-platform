import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html; // For web-based download functionality

class UploadedDocumentsPage extends StatefulWidget {
  const UploadedDocumentsPage({super.key});

  @override
  _UploadedDocumentsPageState createState() => _UploadedDocumentsPageState();
}

class _UploadedDocumentsPageState extends State<UploadedDocumentsPage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<Map<String, dynamic>> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUploadedDocuments();
  }

  Future<void> fetchUploadedDocuments() async {
    try {
      // Reference to the folder in Firebase Storage
      final ListResult result = await storage.ref('EVENT').listAll();

      // Map each item to its metadata retrieval Future
      List<Future<Map<String, dynamic>>> documentFutures = result.items.map((ref) async {
        final FullMetadata metadata = await ref.getMetadata();
        return {
          'name': ref.name,
          'size': metadata.size,
          'url': await ref.getDownloadURL(),
        };
      }).toList();

      // Wait for all metadata retrieval to complete
      final docs = await Future.wait(documentFutures);

      setState(() {
        documents = docs;
        isLoading = false;
      });
    } catch (e) {
      // Handle any errors (e.g., network issues)
      setState(() {
        isLoading = false;
      });
      print('Failed to load documents: $e');
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
                        // Add more fields if needed (e.g., description)
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () async {
                        try {
                          final url = document['url'];
                          // Forcing download by creating a link element (web-specific)
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