import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final List<String> channels = [
  "Sports",
  "News",
  "Technology",
  "Music",
  "Movies",
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // A set to track subscribed channels
  final Set<String> _subscribedChannels = {};

  // Function to subscribe to a channel/topic
  void _subscribeToChannel(String channel) async {
    await FirebaseMessaging.instance.subscribeToTopic(channel);
    setState(() {
      _subscribedChannels.add(channel);
    });
    _showToast("Subscribed to $channel", Colors.green);
  }

  // Function to unsubscribe from a channel/topic
  void _unsubscribeFromChannel(String channel) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
    setState(() {
      _subscribedChannels.remove(channel);
    });
    _showToast("Unsubscribed from $channel", Colors.red);
  }

  // Function to show a toast/snackbar
  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Your Channels"),
        backgroundColor: Colors.blue,
      ),
      body: _subscribedChannels.isEmpty
          ? Center(
        child: Text(
          "No Subscribed Channels",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        itemCount: _subscribedChannels.length,
        itemBuilder: (context, index) {
          String channel = _subscribedChannels.elementAt(index);

          return Card(
            margin:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            child: ListTile(

              title: Text(
                channel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: ElevatedButton.icon(
                onPressed: () {
                  _unsubscribeFromChannel(channel);
                },
                icon: const Icon(Icons.cancel, size: 20),
                label: const Text("Unsubscribe"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChannelSelector(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  // Channel selector dialog
  void _showChannelSelector() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Subscribe to a Channel"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: channels.length,
              itemBuilder: (context, index) {
                String channel = channels[index];
                bool isSubscribed = _subscribedChannels.contains(channel);

                return ListTile(
                  title: Text(channel),
                  trailing: Switch(
                    value: isSubscribed,
                    onChanged: (bool value) {
                      Navigator.of(context).pop();
                      if (value) {
                        _subscribeToChannel(channel);
                      } else {
                        _unsubscribeFromChannel(channel);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
