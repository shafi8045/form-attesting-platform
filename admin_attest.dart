import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For rendering PDF as an image

class PdfAttestationPage extends StatefulWidget {
  final String pdfUrl;

  const PdfAttestationPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PdfAttestationPageState createState() => _PdfAttestationPageState();
}

class _PdfAttestationPageState extends State<PdfAttestationPage> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      // Print the PDF URL for debugging
      print('Loading PDF from URL: ${widget.pdfUrl}');

      // Fetch the PDF from the URL
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load PDF: HTTP ${response.statusCode}');
      }

      // Save the PDF locally
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/document.pdf');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
      localPath = file.path;
      isLoading = false;
    });
  } on http.ClientException catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Network error: Please check your internet connection.';
    });
    print('Network error: $e');
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Error loading PDF: $e';
    });
    print('Error loading PDF: $e');
    }
  }

  Future<void> _attestPdf(String status) async {
  try {
    // Load the existing PDF as an image
    final existingPdfBytes = File(localPath!).readAsBytesSync();
    final pdfImagesStream = Printing.raster(existingPdfBytes);

    // Convert the Stream<PdfRaster> to a List<PdfRaster>
    final pdfImages = await pdfImagesStream.toList();

    // Create a new PDF document
    final pdf = pw.Document();

    // Add each page of the existing PDF as an image to the new PDF
    for (var raster in pdfImages) {
      final imageBytes = await raster.toPng(); // Convert PdfRaster to PNG bytes
      final image = pw.MemoryImage(
        imageBytes, // Use PNG bytes
      );

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image),
            );
          },
        ),
      );
    }

    // Add a new page with the status text
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text(
              status,
              style: pw.TextStyle(
                fontSize: 30,
                color: status == 'Verified' ? PdfColors.green : PdfColors.red,
              ),
            ),
          );
        },
      ),
    );

    // Save the new PDF
    final output = await getTemporaryDirectory();
    final newFile = File('${output.path}/document_$status.pdf');
    await newFile.writeAsBytes(await pdf.save());

    // Extract the first 10 characters of the PDF's name
    final pdfName = newFile.path.split('/').last;
    final folderName = pdfName.substring(0, 10);

    // Upload to Firebase Storage inside the 'users' folder
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users/$folderName/${newFile.path.split('/').last}');
    await storageRef.putFile(newFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF $status and uploaded to Firebase!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error attesting PDF: $e')),
    );
    print('Error attesting PDF: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Attestation')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : PDFView(filePath: localPath),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => _attestPdf('Verified'),
              child: const Text('Attest'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton(
              onPressed: () => _attestPdf('Rejected'),
              child: const Text('Reject'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}