import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flyy_flutter_demo/cart_screen.dart';
import 'package:flyy_flutter_plugin/flyy_flutter_plugin.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //TODO Config 1: Paste Package name from "Settings > Connect SDK" in Dashboard.
  FlyyFlutterPlugin.setPackageName("");
  //TODO Config 2: Paste Partner Id from "Settings > SDK Keys" in Dashboard.
  FlyyFlutterPlugin.initFlyySDK("", FlyyFlutterPlugin.STAGE);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flyy Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flyy Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                //TODO Step 1: Navigate to Offers Page
              },
              child: const Text("Offers"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CartScreen()));
              },
              child: const Text("Open Cart"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FlyyFlutterPlugin.setFlyyUser("test_user_1");
    initFCM();
    listenFCM();
    requestNotificationPermission();
  }

  void initFCM() async {
    final token = await FirebaseMessaging.instance.getToken();
    FlyyFlutterPlugin.sendFCMTokenToServer(token!);
  }

  void requestNotificationPermission() async {
    if (Platform.isIOS) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }
}

void listenFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    if (Platform.isAndroid) {
      if (remoteMessage != null &&
          remoteMessage.data != null &&
          remoteMessage.data.containsKey("notification_source") &&
          remoteMessage.data["notification_source"] != null &&
          remoteMessage.data["notification_source"] == "flyy_sdk") {
        FlyyFlutterPlugin.handleNotification(remoteMessage.data);
      }
    } else if (Platform.isIOS) {
      if (remoteMessage.data.containsKey("notification_source") &&
          remoteMessage.data["notification_source"] != null &&
          remoteMessage.data["notification_source"] == "flyy_sdk") {
        FlyyFlutterPlugin.handleForegroundNotification(remoteMessage.data);
      }
    }
  }).onError((error) {
    print(error);
  });
}

/// It must be a top-level function (e.g. not a class method which requires initialization).
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  print("Background message received");
  if (remoteMessage.data.containsKey("notification_source") &&
      remoteMessage.data["notification_source"] != null &&
      remoteMessage.data["notification_source"] == "flyy_sdk") {
    FlyyFlutterPlugin.handleBackgroundNotification(remoteMessage.data);
  }
}
