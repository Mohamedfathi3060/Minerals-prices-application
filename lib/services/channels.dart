
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/models/channel.dart';

class ChannelService extends GetxController {
  static ChannelService get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<void> addChannel(ChannelModel channel) async {
    try {
      // Add the channel to Firestore
      final newChannelRef = await _db.collection('Channels').add(channel.toJson());

      // Get the channel ID from Firestore document reference
      String channelId = newChannelRef.id;

      // Add an empty messages array under 'channels' key in Firebase Realtime Database
      DatabaseReference realtimeDbRef = FirebaseDatabase.instance.ref('channels/$channelId');

      // Create a new channel entry in Realtime Database with an empty messages array
      await realtimeDbRef.set({
        'title': channel.title,
        'messages': [], // Initializing an empty array of messages
      });

      Get.snackbar("Success", "Channel has been added successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to add the channel. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  // Fetch all channels from Firestore
  Future<List<ChannelModel>> getChannels() async {
    try {
      QuerySnapshot snapshot =
      await _db.collection('Channels').get();
      return snapshot.docs.map((doc) {
        return ChannelModel.fromJson(doc.data() as Map<String, dynamic>,
            id: doc.id);
      }).toList();
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to fetch channels. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      return [];
    }
  }

  // Delete a channel from Firestore and Realtime Database
  Future<void> deleteChannel(String channelId) async {
    try {
      if (channelId.isEmpty) {
        throw Exception("Channel ID is empty");
      }

      // Delete channel from Firestore
      await _db.collection('Channels').doc(channelId).delete();

      // Delete channel from Realtime Database
      DatabaseReference realtimeDbRef = FirebaseDatabase.instance.ref('channels/$channelId');
      await realtimeDbRef.remove();

      Get.snackbar("Success", "Channel has been deleted successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to delete the channel. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  // Fetch a single channel by ID
  Future<ChannelModel?> getChannelById(String channelId) async {
    try {
      DocumentSnapshot doc =
      await _db.collection('Channels').doc(channelId).get();
      if (doc.exists) {
        return ChannelModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        Get.snackbar("Error", "Channel not found.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            colorText: Colors.red);
        return null;
      }
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to fetch the channel. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      return null;
    }
  }

  // Function to subscribe to a channel/topic
  void _subscribeToChannel(String channelId) async {
    await FirebaseMessaging.instance.subscribeToTopic(channelId);
    print('Subscribed to channel: $channelId');
  }

  // Subscribe to a channel
  Future<void> subscribeToChannel(String userId, String channelId) async {
    try {
      DocumentReference userDoc = _db.collection('Users').doc(userId);

      await userDoc.update({
        'subscribedChannelIds': FieldValue.arrayUnion([channelId]),
      });

      // Subscribe user to FCM topic
      _subscribeToChannel(channelId);

      Get.snackbar("Success", "You have subscribed to the channel.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to subscribe to the channel. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }

  // Unsubscribe from a channel
  Future<void> unsubscribeFromChannel(String userId, String channelId) async {
    try {
      DocumentReference userDoc = _db.collection('Users').doc(userId);

      await userDoc.update({
        'subscribedChannelIds': FieldValue.arrayRemove([channelId]),
      });

      // Unsubscribe user from FCM topic
      await FirebaseMessaging.instance.unsubscribeFromTopic(channelId);

      Get.snackbar("Success", "You have unsubscribed from the channel.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar(
          "Error", "Unable to unsubscribe from the channel. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }
}
