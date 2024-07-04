import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_azure_notification_hub/flutter_azure_notification_hub.dart';
import 'package:flutter_azure_notification_hub_example/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseMessaging.instance.requestPermission();
  FlutterAzureNotificationHub.instance.start();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            const Center(
              child: Text('AZ Notification Hubs Plugin Example'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // await _flutterAzureNotificationHubPlugin.start();
                } catch (e) {
                  print(e);
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
