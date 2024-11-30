import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> handleForegroundNotification(RemoteMessage message) async {
  try {
    // Log notification details
    print("***** Foreground Notification Received:");
    print("**** Title: ${message.notification?.title}");
    print("**** Body: ${message.notification?.body}");
    print("**** Sent Time: ${message.sentTime}");

    // Save the notification to Firebase Realtime Database
    await saveNotificationToFirebase(message);

    // Show a local notification
    await showLocalNotification(message);
  } catch (e) {
    print("Error in handling foreground notification: $e");
  }
}

// Function to save the notification to Firebase Realtime Database
Future<void> saveNotificationToFirebase(RemoteMessage message) async {
  try {
    DatabaseReference messagesRef = FirebaseDatabase.instance.ref("messages");
    await messagesRef.push().set({
      'title': message.notification?.title ?? "No title",
      'body': message.notification?.body ?? "No body",
      'date': message.sentTime?.toString() ?? "No date",
    });
    print("Notification saved to Firebase");
  } catch (e) {
    print("Error saving notification to Firebase: $e");
  }
}

// Function to show a local notification
Future<void> showLocalNotification(RemoteMessage message) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id', // Channel ID
      'Default Channel', // Channel Name
      channelDescription: 'Channel for foreground notifications', // Description
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode, // Unique notification ID
      message.notification?.title ?? "No title", // Title
      message.notification?.body ?? "No body", // Body
      notificationDetails, // Notification details
    );
    print("Local notification displayed");
  } catch (e) {
    print("Error displaying local notification: $e");
  }
}

// Background notification handler
@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Background Notification received:");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Sent Time: ${message.sentTime}");

    DatabaseReference notificationsRef =
    FirebaseDatabase.instance.ref("notifications");
    await notificationsRef.push().set({
      'title': message.notification?.title ?? "No title",
      'body': message.notification?.body ?? "No body",
      'date': message.sentTime?.toString() ?? "No date",
    });

    print("Notification saved to Firebase");
  } catch (e) {
    print("Error saving background notification: ${e.toString()}");
  }
}