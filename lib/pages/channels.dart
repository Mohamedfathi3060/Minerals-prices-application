import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/models/channel.dart';
import 'package:minerals_prices/models/message.dart';
import 'package:minerals_prices/pages/chat.dart';
import 'package:minerals_prices/services/channels.dart';
import 'package:minerals_prices/services/chat.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  _ChannelsPageState createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final service = ChannelService();
  final messageService = MessageService();
  String? userId;
  List<String> subscribedChannelIds = [];

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;

      if (email == null) {
        throw Exception("User is not authenticated");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        setState(() {
          userId = userDoc.id;
          subscribedChannelIds =
          List<String>.from(userDoc.data()['subscribedChannelIds'] ?? []);
        });
      } else {
        throw Exception("No user found with the email $email");
      }
    } catch (error) {
      Get.snackbar("Error", "Unable to load user ID: $error",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  void _showAddChannelDialog(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _subscribersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Channel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subscribersController,
                decoration: const InputDecoration(
                  labelText: 'Subscribers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final title = _titleController.text.trim();
              final description = _descriptionController.text.trim();
              final subscribers =
                  int.tryParse(_subscribersController.text.trim()) ?? 0;

              final newChannel = ChannelModel(
                title: title,
                description: description,
                subscribers: subscribers,
                imagePath: 'sports.jpg',
              );
              await service.addChannel(newChannel);

              Get.snackbar("Success", "Channel added successfully!",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green);

              _titleController.clear();
              _descriptionController.clear();
              _subscribersController.clear();

              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _navigateToChatPage(String channelId) {
    Get.to(() => ChatPage(channelId: channelId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ChannelModel>>(
        future: service.getChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No channels found.'));
          }

          final channels = snapshot.data!;
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              final isSubscribed =
              subscribedChannelIds.contains(channel.id);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: channel.imagePath != null &&
                      channel.imagePath!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/${channel.imagePath}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const CircleAvatar(
                      child: Icon(Icons.image_not_supported)),
                  title: Text(
                    channel.title ?? 'No Title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(channel.description ?? 'No Description'),
                      Text(
                        'Subscribers: ${channel.subscribers ?? 0}',
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Channel'),
                            content: Text(
                                'Are you sure you want to delete "${channel.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm) {
                          await service.deleteChannel(channel.id!);
                        }
                      } else if (value == 'subscribe') {
                        if (userId != null) {
                          if (isSubscribed) {
                            await service.unsubscribeFromChannel(
                                userId!, channel.id!);
                            setState(() {
                              subscribedChannelIds.remove(channel.id);
                            });
                          } else {
                            await service.subscribeToChannel(
                                userId!, channel.id!);
                            setState(() {
                              subscribedChannelIds.add(channel.id!);
                            });
                          }
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'subscribe',
                        child: Text(
                          isSubscribed
                              ? 'Unsubscribe'
                              : 'Subscribe',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToChatPage(channel.id!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChannelDialog(context),
        label: const Text('Add Channel'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:minerals_prices/models/channel.dart';
// import 'package:minerals_prices/models/message.dart';
// import 'package:minerals_prices/pages/chat.dart';
// import 'package:minerals_prices/services/channels.dart';
// import 'package:minerals_prices/services/chat.dart';
//
// class ChannelsPage extends StatefulWidget {
//   const ChannelsPage({Key? key}) : super(key: key);
//
//   @override
//   _ChannelsPageState createState() => _ChannelsPageState();
// }
//
// class _ChannelsPageState extends State<ChannelsPage> {
//   final service = ChannelService();
//   final messageService = MessageService();
//   String? userId;
//   List<String> subscribedChannelIds = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchUserId();
//   }
//
//   // Fetch user ID and subscribed channels
//   Future<void> _fetchUserId() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       final email = user?.email;
//
//       if (email == null) {
//         throw Exception("User is not authenticated");
//       }
//
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('Users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();
//
//       if (querySnapshot.docs.isNotEmpty) {
//         final userDoc = querySnapshot.docs.first;
//         setState(() {
//           userId = userDoc.id;
//           subscribedChannelIds =
//           List<String>.from(userDoc.data()['subscribedChannelIds'] ?? []);
//         });
//       } else {
//         throw Exception("No user found with the email $email");
//       }
//     } catch (error) {
//       Get.snackbar("Error", "Unable to load user ID: $error",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.redAccent.withOpacity(0.1),
//           colorText: Colors.red);
//     }
//   }
//
//   // Show a dialog for adding a new channel
//   void _showAddChannelDialog(BuildContext context) {
//     final TextEditingController _titleController = TextEditingController();
//     final TextEditingController _descriptionController =
//     TextEditingController();
//     final TextEditingController _subscribersController =
//     TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add Channel'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(labelText: 'Title'),
//             ),
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(labelText: 'Description'),
//             ),
//             TextField(
//               controller: _subscribersController,
//               decoration: const InputDecoration(labelText: 'Subscribers'),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final title = _titleController.text.trim();
//               final description = _descriptionController.text.trim();
//               final subscribers =
//                   int.tryParse(_subscribersController.text.trim()) ?? 0;
//
//               final newChannel = ChannelModel(
//                 title: title,
//                 description: description,
//                 subscribers: subscribers,
//                 imagePath: 'sports.jpg',
//               );
//               await service.addChannel(newChannel);
//
//               Get.snackbar("Success", "Channel added successfully!",
//                   snackPosition: SnackPosition.BOTTOM,
//                   backgroundColor: Colors.green.withOpacity(0.1),
//                   colorText: Colors.green);
//
//               _titleController.clear();
//               _descriptionController.clear();
//               _subscribersController.clear();
//
//               Navigator.of(context).pop(); // Close the dialog
//             },
//             child: const Text('Add'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Navigate to the chat page of the selected channel
//   void _navigateToChatPage(String channelId) {
//     Get.to(() => ChatPage(channelId: channelId));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Channels'),
//       ),
//       body: userId == null
//           ? const Center(child: CircularProgressIndicator())
//           : FutureBuilder<List<ChannelModel>>(
//         future: service.getChannels(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No channels found.'));
//           }
//
//           final channels = snapshot.data!;
//           return ListView.builder(
//             itemCount: channels.length,
//             itemBuilder: (context, index) {
//               final channel = channels[index];
//               final isSubscribed =
//               subscribedChannelIds.contains(channel.id);
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(
//                     vertical: 8, horizontal: 16),
//                 child: ListTile(
//                   leading: channel.imagePath != null &&
//                       channel.imagePath!.isNotEmpty
//                       ? Image.asset(
//                     'assets/images/${channel.imagePath}',
//                     width: 50,
//                     height: 50,
//                     fit: BoxFit.cover,
//                   )
//                       : const CircleAvatar(
//                       child: Icon(Icons.image_not_supported)),
//                   title: Text(channel.title ?? 'No Title'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(channel.description ?? 'No Description'),
//                       Text('Subscribers: ${channel.subscribers ?? 0}'),
//                     ],
//                   ),
//                   trailing: Wrap(
//                     spacing: 12,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () async {
//                           bool confirm = await showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text('Delete Channel'),
//                               content: Text(
//                                   'Are you sure you want to delete "${channel.title}"?'),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.of(context).pop(false),
//                                   child: const Text('Cancel'),
//                                 ),
//                                 TextButton(
//                                   onPressed: () =>
//                                       Navigator.of(context).pop(true),
//                                   child: const Text('Delete'),
//                                 ),
//                               ],
//                             ),
//                           );
//
//                           if (confirm) {
//                             await service.deleteChannel(channel.id!);
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           isSubscribed
//                               ? Icons.unsubscribe
//                               : Icons.subscriptions,
//                           color:
//                           isSubscribed ? Colors.orange : Colors.blue,
//                         ),
//                         onPressed: () async {
//                           if (userId != null) {
//                             if (isSubscribed) {
//                               await service.unsubscribeFromChannel(
//                                   userId!, channel.id!);
//                               setState(() {
//                                 subscribedChannelIds.remove(channel.id);
//                               });
//                             } else {
//                               await service.subscribeToChannel(
//                                   userId!, channel.id!);
//                               setState(() {
//                                 subscribedChannelIds.add(channel.id!);
//                               });
//                             }
//                           }
//                         },
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.chat, color: Colors.blue),
//                         onPressed: () {
//                           _navigateToChatPage(channel.id!);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddChannelDialog(context),
//         child: const Icon(Icons.add),
//         tooltip: 'Add Channel',
//       ),
//     );
//   }
// }
//

