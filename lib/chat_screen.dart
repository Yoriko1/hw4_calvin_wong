import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String boardName;

  ChatScreen({required this.boardName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  void _sendMessage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If the user is not logged in, we show a message and return
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You need to log in first.")));
      return;
    }

    if (_messageController.text.isNotEmpty) {
      try {
        // Fetch the user's first name from Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String firstName = userDoc['first_name'] ?? 'Anonymous'; // Default to 'Anonymous' if not available

        // Save message with first name
        await _firestore.collection('message_boards')
            .doc(widget.boardName)  // Use board name as the document ID
            .collection('messages')  // Store messages under a collection
            .add({
          'username': firstName,  // Store first name
          'message': _messageController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        _messageController.clear();  // Clear the input field after sending the message
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send message.")));
      }
    }
  }

  // Function to fetch the messages for the selected board
  Stream<QuerySnapshot> _fetchMessages() {
    return _firestore.collection('message_boards')
        .doc(widget.boardName)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();  // Stream to get real-time updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
      ),
      body: Column(
        children: [
          // Display messages in a list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,  // So the newest messages appear at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message['username'] ?? 'Anonymous'), // Show the user's first name
                      subtitle: Text(message['message']),
                      trailing: Text(message['timestamp'] != null
                          ? (message['timestamp'] as Timestamp).toDate().toString()
                          : 'No timestamp'),
                    );
                  },
                );
              },
            ),
          ),

          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
