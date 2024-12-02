import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/models/message.dart';
import 'package:minerals_prices/services/chat.dart';

class ChatPage extends StatefulWidget {
  final String channelId;

  const ChatPage({Key? key, required this.channelId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService messageService = MessageService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? channelTitle;

  @override
  void initState() {
    super.initState();
    _getChannelTitle();
  }

  // Fetch the channel title from Firestore
  Future<void> _getChannelTitle() async {
    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('Channels')
          .where('id', isEqualTo: widget.channelId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          channelTitle = userDoc[
          'title']; // Assuming 'title' is the field for the channel's name
        });
      }
    } catch (e) {
      print("Error fetching channel title: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(channelTitle ??
            'Loading...'), // Show title or 'Loading...' until it is fetched
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream:
              messageService.getMessagesStreamByChannelId(widget.channelId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.username ?? 'Unknown User'),
                      subtitle: Text(message.text ?? ""),
                    );
                  },
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Query the Users collection where the email matches
                        final QuerySnapshot querySnapshot = await firestore
                            .collection('Users')
                            .where('email', isEqualTo: user.email)
                            .get();
                        final userDoc = querySnapshot.docs.first;
                        final username = userDoc['username'];

                        final message = MessageModel(
                          username: username,
                          userId: user.uid,
                          userEmail: user.email,
                          text: _messageController.text.trim(),
                          dateTime: DateTime.now(),
                        );
                        await messageService.addMessage(
                            widget.channelId, message);
                        _messageController.clear();
                      } else {
                        Get.snackbar("Error", "User not authenticated",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            colorText: Colors.red);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
