import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minerals_prices/models/channel.dart';
import 'package:minerals_prices/pages/chat.dart';
import 'package:minerals_prices/services/channels.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({Key? key}) : super(key: key);

  @override
  _ChannelsPageState createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final ChannelService service = ChannelService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? userId;
  List<String> subscribedChannelIds = [];

  @override
  void initState() {
    super.initState();
    FirebaseInAppMessaging.instance.setMessagesSuppressed(false);
    _fetchUserId();
  }

  @override
  void dispose() {
    FirebaseInAppMessaging.instance.setMessagesSuppressed(true);
    super.dispose();
  }

  Future<void> _fetchUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (email == null) {
        throw Exception("User is not authenticated");
      }

      final querySnapshot = await firestore
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
      Get.snackbar(
        "Error",
        "Unable to load user ID: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _showAddChannelDialog(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _subscribersController = TextEditingController();
    String _selectedImage = 'default.jpg';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Add Channel',
                          style: GoogleFonts.montserrat(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // White color for text and icons
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.indigo[700],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Select Channel Image',
                                    style: GoogleFonts.montserrat(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        'tree.jpg',
                                      ]
                                          .map((image) => ListTile(
                                        title: Text(image),
                                        leading: Image.asset(
                                          'assets/images/tree.jpg',
                                          width: 40,
                                          height: 40,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.black,
                                              ),
                                            );
                                          },
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedImage = image;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/tree.jpg',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.white, // White color for text and icons
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Select Channel Image',
                                  style: GoogleFonts.montserrat(
                                    textStyle: const TextStyle(
                                      color: Colors.white, // White color for text and icons
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _titleController,
                          style: TextStyle(color: Colors.white), // White color for text and icons
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // White color for text and icons
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _descriptionController,
                          style: TextStyle(color: Colors.white), // White color for text and icons
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // White color for text and icons
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _subscribersController,
                          style: TextStyle(color: Colors.white), // White color for text and icons
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Subscribers',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)), // White color for text and icons
                            filled: true,
                            fillColor: Colors.black,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white), // White color for text and icons
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black, // White color for text and icons
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (_titleController.text.trim().isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter a title",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                                    colorText: Colors.red, // Red color for delete action
                                  );
                                  return;
                                }

                                final newChannel = ChannelModel(
                                  title: _titleController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  subscribers: int.tryParse(_subscribersController.text.trim()) ?? 0,
                                  imagePath: _selectedImage,
                                );
                                await service.addChannel(newChannel);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.teal, // Teal color for accent elements like buttons
                                backgroundColor: Colors.white, // White color for text and icons
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: Text(
                                'Add',
                                style: GoogleFonts.montserrat(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black, // White color for text and icons
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChannelActions(ChannelModel channel, bool isSubscribed) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Delete Channel',
                  style: GoogleFonts.montserrat(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete "${channel.title}"?',
                  style: GoogleFonts.montserrat(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red), // Red color for delete action
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await service.deleteChannel(channel.id!);
            }
          },
          icon: const Icon(Icons.delete, color: Colors.red), // Red color for delete action
          label: Text(
            'Delete',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(color: Colors.red), // Red color for delete action
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            if (userId != null) {
              if (isSubscribed) {
                await service.unsubscribeFromChannel(userId!, channel.id!);
                setState(() {
                  subscribedChannelIds.remove(channel.id);
                });
              } else {
                await service.subscribeToChannel(userId!, channel.id!);
                setState(() {
                  subscribedChannelIds.add(channel.id!);
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You must log in first to manage subscriptions.'),
                  backgroundColor: Colors.red, // Red color for delete action
                ),
              );
            }
          },
          icon: Icon(
            isSubscribed ? Icons.unsubscribe : Icons.subscriptions,
            color: isSubscribed ? Colors.orange : Colors.teal, // Teal color for accent elements like buttons
          ),
          label: Text(
            isSubscribed ? 'Unsubscribe' : 'Subscribe',
            style: GoogleFonts.montserrat(
              textStyle: TextStyle(
                color: isSubscribed ? Colors.orange : Colors.teal, // Teal color for accent elements like buttons
              ),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              Get.to(() => ChatPage(channelId: channel.id!));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You must log in first to access the chat.'),
                  backgroundColor: Colors.red, // Red color for delete action
                ),
              );
            }
          },
          icon: const Icon(Icons.chat,
            color: Colors.teal, // Teal color for accent elements like buttons
          ),
          label: Text(
            'Chat',
            style: GoogleFonts.montserrat(
              textStyle: const TextStyle(
                color: Colors.teal, // Teal color for accent elements like buttons
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelItem(ChannelModel channel, bool isSubscribed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Black color for container background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ), // Circular only on the left side
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              'assets/images/tree.jpg',
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: 120,
                  color: Colors.grey[800], // Dark grey color for error placeholder
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.white.withOpacity(0.5), // White color for text and icons
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.title ?? 'No Title',
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // White color for text and icons
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    channel.description ?? 'No Description',
                    style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black.withOpacity(0.7), // White color for text and icons
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChannelActions(channel, isSubscribed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFE32C),
                  Color(0xFF52ACFF),

                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.black, // White color for text and icons
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Channels',
                        style: GoogleFonts.montserrat(
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black, // White color for text and icons
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Channels')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No channels found.',
                            style: GoogleFonts.montserrat(
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.white, // White color for text and icons
                              ),
                            ),
                          ),
                        );
                      }

                      final channels = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return ChannelModel(
                          id: doc.id,
                          title: data['title'],
                          description: data['description'],
                          subscribers: data['subscribers'],
                          imagePath: data['imagePath'] ?? 'default.jpg',
                        );
                      }).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: channels.length,
                        itemBuilder: (context, index) {
                          final channel = channels[index];
                          final isSubscribed = subscribedChannelIds.contains(channel.id);
                          return _buildChannelItem(channel, isSubscribed);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal, // Teal color for accent elements like buttons
        onPressed: () => _showAddChannelDialog(context),
        child: const Icon(Icons.add, color: Colors.black), // White color for text and icons
      ),
    );
  }
}

