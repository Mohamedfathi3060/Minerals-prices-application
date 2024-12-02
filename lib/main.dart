import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:minerals_prices/pages/login.dart';
import 'package:minerals_prices/services/channels.dart';
import 'package:minerals_prices/services/chat.dart';
import 'package:minerals_prices/services/notifications.dart';

import 'firebase_options.dart';


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
  String? token = await FirebaseMessaging.instance.getToken();
  print('Firebase Token: $token');

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
      home: Login(),
    );
  }
}