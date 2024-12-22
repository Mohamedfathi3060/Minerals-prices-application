import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/models/user.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class UserService extends GetxController {
  static UserService get instance => Get.find();
  final _db = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Check if an email exists in Firestore
  Future<bool> doesEmailExist(String email) async {
    try {
      // Query Firestore to check for matching email
      QuerySnapshot snapshot = await _db
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Return true if a matching document exists, otherwise false
      return snapshot.docs.isNotEmpty;
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to verify email.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      return false;
    }
  }

  // Create a new user in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      // Ensure data is added to Firestore
      await _db.collection('Users').add(user.tojson());

      // Show success message after the user is added
      Future.delayed(Duration.zero, () {
        Get.snackbar("Success", "Your account has been created",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green);
      });

      _analytics.logEvent(
        name: 'first_login',
        parameters: {
          'user_id': user.email ?? 'Unknown',
          'display_name': user.username ?? 'Unknown',
        },
      ).then((val) {
        print("Singin up new User");
      }).catchError((err) {
        print("Error Singing up new user");
      });
    } catch (error, stacktrace) {
      // Show error message if something goes wrong
      print("Error: $error, StackTrace: $stacktrace");
      Future.delayed(Duration.zero, () {
        Get.snackbar("Error", "Something went wrong. Try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withOpacity(0.1),
            colorText: Colors.red);
      });
    }
  }

  // List all users from Firestore
  Future<List<UserModel>> getUsers() async {
    try {
      QuerySnapshot snapshot = await _db.collection('Users').get();
      List<UserModel> usersList = snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return usersList;
    } catch (error, stacktrace) {
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Unable to fetch users.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      return [];
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection('Users').doc(userId).delete();

      // Show success message after user is deleted
      Get.snackbar("Success", "User has been deleted.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
    } catch (error, stacktrace) {
      // Show error message if something goes wrong
      print("Error: $error, StackTrace: $stacktrace");
      Get.snackbar("Error", "Something went wrong. Try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
    }
  }
}
