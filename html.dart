import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenGoogleSupportPage extends StatelessWidget {
  const OpenGoogleSupportPage({super.key});

  final String url = "https://support.google.com/chrome/?p=help&ctx=keyboard#topic=7439538";

  Future<void> _launchURL() async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Support")),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchURL,
          child: const Text("Open Google Support"),
        ),
      ),
    );
  }
}
