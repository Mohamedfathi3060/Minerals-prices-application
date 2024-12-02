import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/message.dart';

class MessageService extends GetxController {
  // static MessageService get instance => Get.find<MessageService>();
  static MessageService get instance => Get.find();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Convert getMessagesStreamByChannelId to return a Stream of messages
  Stream<List<MessageModel>> getMessagesStreamByChannelId(String channelId) {
    print(channelId);
    print("Doaa");
    return _db.child("channels/$channelId/messages").onValue.map((event) {
      print("Doaa1");
      if (event.snapshot.exists) {
        print("Doaa6");
        Map<dynamic, dynamic>? messagesMap =
        event.snapshot.value as Map<dynamic, dynamic>?;
        print("Doaa13");
        if (messagesMap != null) {
          print("Doaa4");
          // Convert the messages map to a list of MessageModel
          return messagesMap.entries.map((entry) {
            Map<String, dynamic> messageData =
            Map<String, dynamic>.from(entry.value);
            return MessageModel.fromJson(messageData);
          }).toList();
        }
      }
      return []; // Return an empty list if no messages are found
    });
  }

  // Append a new message to a specific channelId
  Future<void> addMessage(String channelId, MessageModel message) async {
    try {
      DatabaseReference channelRef = _db.child("channels/$channelId/messages");

      // Check if the channel exists by getting the snapshot
      DatabaseEvent event = await channelRef.once(); // Get the DatabaseEvent
      if (!event.snapshot.exists) {
        // Channel doesn't exist, create a new one
        await channelRef
            .set({}); // Create an empty object or initial data if needed
      }

      // Generate a new unique key for the message
      String newMessageKey = channelRef.push().key!;

      // Save the message to the database under 'messages'
      await channelRef.child(newMessageKey).set(message.toJson());

      Get.snackbar("Success", "Message added successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error) {
      Get.snackbar("Error", "Failed to add message: $error",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  // Delete a specific message from a channelId
  Future<void> deleteMessage(String channelId, String messageId) async {
    try {
      await _db.child("channels/$channelId/messages/$messageId").remove();
      Get.snackbar("Success", "Message deleted successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error) {
      Get.snackbar("Error", "Failed to delete message: $error",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }
}
