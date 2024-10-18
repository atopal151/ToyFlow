import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Sohbetler",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
               
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.chat_bubble,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text("Chat Screen"),
      ),
    );
  }
}
