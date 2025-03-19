import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'admin_attest.dart'; // Import the attestation page

class CertificateListPage extends StatefulWidget {
  const CertificateListPage({super.key});

  @override
  _CertificateListPageState createState() => _CertificateListPageState();
}

class _CertificateListPageState extends State<CertificateListPage> {
  List<String> pdfUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPdfs();
  }

  Future<void> fetchPdfs() async {
    final storageRef = FirebaseStorage.instance.ref().child('certificate'); 
    final result = await storageRef.listAll();

    final urls = await Future.wait(
      result.items.map((item) => item.getDownloadURL()),
    );

    setState(() {
      pdfUrls = urls;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select PDF')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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