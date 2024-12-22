import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

// Function to handle foreground notifications
void foregroundNotificationHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print("Notification received:");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Sent Time: ${message.sentTime}");

    // Save message to Firebase Realtime Database
    DatabaseReference messagesRef = FirebaseDatabase.instance.ref("messages");
    await messagesRef.push().set({
      'title': message.notification?.title ?? "No title",
      'body': message.notification?.body ?? "No body",
      'date': message.sentTime?.toString() ?? "No date",
    });

    print("Message saved to Firebase");

    // Show local notification
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        message.notification!.title, // Title
        message.notification!.body, // Body
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id', // Channel ID
            'Default Channel', // Channel Name
            channelDescription:
            'Your notification description', // Channel Description
            importance: Importance.high,
            priority: Priority.high,
            showWhen: false,
          ),
        ),
      );
    }
  } catch (e) {
    print("Error saving notification: ${e.toString()}");
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
