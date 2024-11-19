import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBoardScreen extends StatelessWidget {
  final String boardName;

  MessageBoardScreen({required this.boardName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(boardName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('message_boards').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var boards = snapshot.data!.docs;
          return ListView.builder(
            itemCount: boards.length,
            itemBuilder: (context, index) {
              var board = boards[index];
              return ListTile(
                title: Text(board['name']),
                leading: Icon(Icons.chat),
                onTap: () {
                  // Navigate to chat screen
                },
              );
            },
          );
        },
      ),
    );
  }
}
