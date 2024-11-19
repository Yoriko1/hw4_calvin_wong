import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart'; 
import 'splash_screen.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';  // Import the ChatScreen to navigate

class HomeScreen extends StatelessWidget {
  // List of message boards
  final List<Map<String, String>> messageBoards = [
    {'name': 'Games', 'icon': 'assets/game.jpg'},
    {'name': 'Food', 'icon': 'assets/food.png'},
    {'name': 'Studying', 'icon': 'assets/study.png'},
    {'name': 'Exercise', 'icon': 'assets/exercise.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Boards'),
      ),
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
                  Text('User Name', style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            // Home item (Message Boards)
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                // Close the drawer and stay on the current screen
                Navigator.pop(context);
              },
            ),
            // Profile item
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // Navigate to Profile Screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
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
                ); // Navigate to Splash Screen after logout
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          var board = messageBoards[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(board['icon']!, width: 50, height: 50),
              title: Text(board['name']!),
              onTap: () {
                // Navigate to the chat window with the selected board name
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(boardName: board['name']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
