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
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CartScreen()));
                },
                child: const Text("Open Cart"))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FlyyFlutterPlugin.setPackageName("com.example.flyyxintegration");
    FlyyFlutterPlugin.initFlyySDK(
        "35299df860c15c0449c8", FlyyFlutterPlugin.STAGE);
    FlyyFlutterPlugin.setFlyyUser("user008");
    initFCM();
    listenFCM();
  }

  void initFCM() async {
    final token = await FirebaseMessaging.instance.getToken();
    FlyyFlutterPlugin.sendFCMTokenToServer(token!);
  }
}

void listenFCM() {
  FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) {
    if (remoteMessage != null &&
        remoteMessage.data != null &&
        remoteMessage.data.containsKey("notification_source") &&
        remoteMessage.data["notification_source"] != null &&
        remoteMessage.data["notification_source"] == "flyy_sdk") {
      FlyyFlutterPlugin.handleNotification(remoteMessage.data);
    }
  });
}
