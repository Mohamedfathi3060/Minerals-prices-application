/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notify/splash_screen.dart';
import 'firebase_options.dart';
import 'notification_handler.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Handle foreground and background notifications
  FirebaseMessaging.onMessage.listen(foregroundNotificationHandler);
  FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      //home: MyHomePage(),
      home: SplashToHome(),
    );
  }
}

*/
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minerals_prices/pages/splash.dart';
import 'package:minerals_prices/services/chat.dart';

import 'package:minerals_prices/services/notifications.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

import 'firebase_options.dart';

// Create an instance of the FlutterLocalNotificationsPlugin

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.testMode = true;
  // Get.put(MessageService());
  Get.lazyPut(() => MessageService());
  // Get.lazyPut(() => ChannelService());
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // String? token = await FirebaseMessaging.instance.getToken();
  // print('Firebase Token: $token');

  // Initialize local notifications
  await initializeLocalNotifications();

  // Set up Firebase Messaging handlers
  FirebaseMessaging.onMessage.listen(foregroundNotificationHandler);
  FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}