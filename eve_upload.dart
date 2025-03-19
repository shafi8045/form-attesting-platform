import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

class DocumentUploadPage extends StatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  bool _isUploading = false;
  List<Map<String, dynamic>> documents = [];

  @override
  void initState() {
    super.initState();
    fetchUploadedDocuments();
  }

  Future<void> fetchUploadedDocuments() async {
    try {
      final ListResult result = await FirebaseStorage.instance.ref('EVENT').listAll();
      
      List<Future<Map<String, dynamic>>> documentFutures = result.items.map((ref) async {
        final FullMetadata metadata = await ref.getMetadata();
        return {
          'name': ref.name,
          'size': metadata.size,
          'url': await ref.getDownloadURL(),
          'ref': ref
        };
      }).toList();

      final docs = await Future.wait(documentFutures);

      setState(() {
        documents = docs;
      });
    } catch (e) {
      print('Failed to load documents: $e');
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        Uint8List fileBytes = result.files.single.bytes!;
        String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + result.files.single.name;

        Reference ref = FirebaseStorage.instance.ref('EVENT/$fileName');
        UploadTask uploadTask = ref.putData(fileBytes);
        await uploadTask;

        await fetchUploadedDocuments();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteFile(Reference ref) async {
    try {
      await ref.delete();
      await fetchUploadedDocuments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event PDFs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isUploading ? null : _uploadFile,
              child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload PDF'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: Text(document['name']),
                    subtitle: Text('Size: ${document['size']} bytes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            final url = document['url'];
                            await launchUrl(Uri.parse(url));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFile(document['ref']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
