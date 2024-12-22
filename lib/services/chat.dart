import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/services/analytics_service.dart';
import '../models/message.dart';

class MessageService extends GetxController {
  static MessageService get instance => Get.find();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Stream to fetch messages in the correct order (newest at the bottom)
  Stream<List<MessageModel>> getMessagesStreamByChannelId(String channelId) {
    return _db.child("channels/$channelId/messages").onValue.map((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic>? messagesMap =
        event.snapshot.value as Map<dynamic, dynamic>?;
        if (messagesMap != null) {
          // Convert the messages map to a list of MessageModel
          List<MessageModel> messages = messagesMap.entries.map((entry) {
            Map<String, dynamic> messageData =
            Map<String, dynamic>.from(entry.value);
            return MessageModel.fromJson(messageData);
          }).toList();

          // Sort messages by dateTime in descending order (newest first)
          messages.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return messages;
        }
      }
      return []; // Return an empty list if no messages are found
    });
  }

  // Add a new message to the specified channel
  Future<void> addMessage(String channelId, MessageModel message) async {
    try {
      DatabaseReference channelRef = _db.child("channels/$channelId/messages");

      // Ensure the channel's messages node exists, if not, create it
      DatabaseEvent event = await channelRef.once();
      if (!event.snapshot.exists) {
        await channelRef.set({});
      }

      // Add the new message with a unique key
      String newMessageKey = channelRef.push().key!;
      await channelRef.child(newMessageKey).set(message.toJson());

      final user = FirebaseAuth.instance.currentUser;
      String email = "";
      if (user == null) {
        email = "unknown";
      } else {
        email = user.email!;
      }
      AnalyticsService analytics = AnalyticsService();
      analytics
          .logPushMessageEvent(userId: email, content: message.text!)
          .then((val) {
        print("pushing Message Event");
      });

      // Show success message
      Get.snackbar(
        "Success",
        "Message added successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (error) {
      // Show error message if something goes wrong
      Get.snackbar(
        "Error",
        "Failed to add message: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Delete a message from the specified channel
  Future<void> deleteMessage(String channelId, String messageId) async {
    try {
      // Remove the message by its ID
      await _db.child("channels/$channelId/messages/$messageId").remove();

      // Show success message
      Get.snackbar(
        "Success",
        "Message deleted successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (error) {
      // Show error message if something goes wrong
      Get.snackbar(
        "Error",
        "Failed to delete message: $error",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
