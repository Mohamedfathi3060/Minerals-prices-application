import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatPage extends StatefulWidget {
  final String channelId;

  const ChatPage({Key? key, required this.channelId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  String? _channelTitle;

  @override
  void initState() {
    super.initState();
    _fetchChannelTitle();
  }

  Future<void> _fetchChannelTitle() async {
    final channelDoc = await _firestore.collection('Channels').doc(widget.channelId).get();
    setState(() {
      _channelTitle = channelDoc.data()?['title'] ?? 'Chat';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _channelTitle ?? 'Chat',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Channels')
          .doc(widget.channelId)
          .collection('Messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message['userId'] == FirebaseAuth.instance.currentUser?.uid;

            return Align(
              alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.black : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['username'] ?? 'Unknown User',
                      style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['text'] ?? '',
                      style: GoogleFonts.raleway(
                        textStyle: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _messageController.text.isNotEmpty) {
      await _firestore
          .collection('Channels')
          .doc(widget.channelId)
          .collection('Messages')
          .add({
        'text': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
      });
      _messageController.clear();
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}
