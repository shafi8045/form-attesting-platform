import 'package:flutter/material.dart';
// import 'package:project2/admin_home.dart';
// import 'package:project2/admin_home.dart';
// import 'package:project2/forgot.dart';
// import 'package:project2/home.dart';
//import 'package:project2/notification.dart';
// import 'package:project2/req.dart';
// import 'package:project2/signup.dart';
// import 'package:project2/apload.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:project2/req_list_page.dart';
import 'package:project2/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
       home: const LoginScreen(),
      // home: OpenGoogleSupportPage(),
      // home: const admin_home(),
    );
  }
}
