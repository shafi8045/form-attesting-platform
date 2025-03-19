import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CertificatePage());
}

class CertificatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RequestFormScreen(),
    );
  }
}

class RequestFormScreen extends StatefulWidget {
  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _submitInController = TextEditingController();

  String fullName = "";
  String registerNumber = "";
  String department = "";
  String selectedCertificate = "SSLC Certificate"; // Default selection
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('user informations')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            fullName = userDoc.data()?['Full Name'] ?? "";
            registerNumber = userDoc.data()?['Register Number'] ?? "";
            department = userDoc.data()?['department'] ?? "";
          });
        } else {
          print("User document does not exist!");
        }
      } catch (e) {
        print("Error fetching user info: $e");
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveToFirebase() async {
  if (_formKey.currentState!.validate()) {
    final pdf = pw.Document();

    // Get the current date and time
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now); // Format date
    final formattedTime = DateFormat('HH:mm:ss').format(now); // Format time

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('From', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Full Name: $fullName',
                style: pw.TextStyle(color: PdfColors.black, fontSize: 14)),
            pw.Text('Register Number: $registerNumber',
                style: pw.TextStyle(color: PdfColors.black, fontSize: 14)),
            pw.Text('Department: $department', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 50),
            pw.Text('To', style: pw.TextStyle(fontSize: 14)),
            pw.Text('Principal', style: pw.TextStyle(fontSize: 14)),
            pw.Text('IPT & GPTC Shoranur', style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 50),
            pw.Text(
                'I am $fullName, a student of computer engineering, register number $registerNumber. I am writing to formally request the temporary issuance of my $selectedCertificate for a period of ${_submitInController.text}.',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 10),
            pw.Text(
                'The certificate is required for ${_purposeController.text}, and I assure you that I will return it promptly within ${_submitInController.text}. I kindly request your approval for this and would be grateful for your support in processing my request at the earliest.',
                style: pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 150),
            pw.Text('Date: $formattedDate', // Add formatted date
                style: pw.TextStyle(color: PdfColors.black, fontSize: 14)),
            pw.Text('Time: $formattedTime', // Add formatted time
                style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );

    Uint8List pdfData = await pdf.save();

    try {
      String fileName = "${registerNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      Reference storageRef = FirebaseStorage.instance.ref().child('certificate/$fileName');

      await storageRef.putData(pdfData);

      await FirebaseFirestore.instance.collection('forms').add({
        "fileName": fileName,
        "uploadedAt": DateTime.now(),
        "uploadedBy": fullName,
        "registerNumber": registerNumber,
        "department": department,
        "certificate": selectedCertificate,
        "purpose": _purposeController.text,
        "submitIn": _submitInController.text,
        "date": _selectedDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Form saved successfully in principal folder as PDF!")),
      );

      _purposeController.clear();
      _submitInController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save form: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requesting Documents Form"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Full Name: $fullName"),
              Text("Register Number: $registerNumber"),
              Text("Department: $department"),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCertificate,
                decoration: InputDecoration(labelText: "Required Certificate"),
                items: ["SSLC Certificate", "+2 Certificate"].map((certificate) {
                  return DropdownMenuItem(
                    value: certificate,
                    child: Text(certificate),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCertificate = value!;
                  });
                },
              ),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(labelText: "Purpose"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the purpose.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _submitInController,
                decoration: InputDecoration(labelText: "Submit In"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the submission details.";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveToFirebase,
                child: Text("Submit Form"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}