import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('user informations')
          .doc(user.uid)
          .get();

      return userDoc.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 208, 207, 208),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 200, 199, 201),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text(
                'Error fetching profile information',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final userData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileInfoItem(icon: Icons.person, label: 'Name', value: userData['Full Name'] ?? 'Not Available'),
                const SizedBox(height: 10),
                ProfileInfoItem(icon: Icons.phone, label: 'Phone Number', value: userData['Phone Number'] ?? 'Not Available'),
                const SizedBox(height: 10),
                ProfileInfoItem(icon: Icons.assignment_ind, label: 'Register Number', value: userData['Register Number'] ?? 'Not Available'),
                const SizedBox(height: 10),
                ProfileInfoItem(icon: Icons.email, label: 'Email', value: userData['Email'] ?? 'Not Available'),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(userData: userData),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 196, 196, 197),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController registerNumberController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['Full Name']);
    phoneController = TextEditingController(text: widget.userData['Phone Number']);
    registerNumberController = TextEditingController(text: widget.userData['Register Number']);
  }

  Future<void> _updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('user informations').doc(user.uid).update({
        'Full Name': nameController.text,
        'Phone Number': phoneController.text,
        'Register Number': registerNumberController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
              const SizedBox(height: 10),
              TextFormField(controller: registerNumberController, decoration: const InputDecoration(labelText: 'Register Number')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserData,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoItem({Key? key, required this.icon, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 22, 22, 22), size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Text('$label: $value',
              style: const TextStyle(color: Color.fromARGB(255, 18, 18, 18), fontSize: 18, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
