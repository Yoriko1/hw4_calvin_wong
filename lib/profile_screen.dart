import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';  // Import HomeScreen
import 'settings_screen.dart';  // Import SettingsScreen
import 'splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _errorMessage;  // Variable to store error messages
  bool _isLoading = false; // To show a loading indicator while updating

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore
  _loadUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userData.exists) {
          _firstNameController.text = userData['first_name'] ?? '';
          _lastNameController.text = userData['last_name'] ?? '';
        } else {
          // If user data doesn't exist in Firestore, create a default user profile.
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'first_name': '',
            'last_name': '',
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error loading user data: $e';
        });
      }
    }
  }

  // Save the updated user data
  _saveProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _errorMessage = 'User not logged in';
      });
      return;
    }

    // Validate the input
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both first name and last name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;  // Clear any previous error message
    });

    try {
      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
      });

      setState(() {
        _isLoading = false;
        _errorMessage = 'Profile updated successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error saving profile: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("User not logged in"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                );
                },
                child: Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${_firstNameController.text} ${_lastNameController.text}', // Display user's full name
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            // Home item (Message Boards)
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Navigate to Home Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            // Profile item
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Stay on Profile screen (close drawer)
                Navigator.pop(context);
              },
            ),
            // Settings item
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigate to Settings Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            // Logout item
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                ); // Navigate to Login screen after logout
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display error or success messages
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            SizedBox(height: 20),

            // First Name input field
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Last Name input field
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Save button
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text("Save Changes"),
                  ),
          ],
        ),
      ),
    );
  }
}
