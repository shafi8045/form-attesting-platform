// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'home.dart'; // Ensure this import is correct

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Corrected method name
  await Firebase.initializeApp(); // Corrected method name
  runApp(FormPage());
}

class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Corrected syntax
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
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  String fullName = "";
  String registerNumber = "";
  String department = "";
  String selectedRecipient = "HOD CT"; // Default selection

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

  Future<void> _saveToFirebase() async {
    if (_formKey.currentState!.validate()) {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Requesting Form",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 30),
              pw.Text("From:", style: pw.TextStyle(fontSize: 14)),
              pw.Text("Full Name: $fullName", style: pw.TextStyle(fontSize: 14)),
              pw.Text("Register Number: $registerNumber", style: pw.TextStyle(fontSize: 14)),
              pw.Text("Department: $department", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 50),
              pw.Text("To: $selectedRecipient", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 50),
              pw.Text("Subject: ${_subjectController.text}", style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 50),
              pw.Text("Content:", style: pw.TextStyle(fontSize: 14)),
              pw.Text(_contentController.text),
              pw.SizedBox(height: 150),
              pw.Text("Date&Time: ${DateTime.now().toIso8601String()}", style: pw.TextStyle(fontSize: 14)),
            ],
          ),
        ),
      );

      Uint8List pdfData = await pdf.save();

      try {
        String fileName = "${registerNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        Reference storageRef = FirebaseStorage.instance.ref().child('$selectedRecipient/$fileName');

        await storageRef.putData(pdfData);

        await FirebaseFirestore.instance.collection('forms').add({
          "fileName": fileName,
          "uploadedAt": DateTime.now(),
          "uploadedBy": fullName,
          "registerNumber": registerNumber,
          "department": department,
          "recipient": selectedRecipient,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Requst successfully recieved to $selectedRecipient ")),
        );

        _subjectController.clear();
        _contentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send request: $e")),
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
                value: selectedRecipient,
                decoration: InputDecoration(labelText: "To"),
                items: ["HOD CT", "principal"].map((recipient) {
                  return DropdownMenuItem(
                    value: recipient,
                    child: Text(recipient),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRecipient = value!;
                  });
                },
              ),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: "Subject"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the subject.";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: "Content"),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the content.";
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