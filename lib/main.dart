import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PSLNotify());
}

class PSLNotify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('this is the text'),
            MessageHandler(),
          ],
        ),
      ),
    );
  }
}

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String permissionStatus = ' ';
  Future<RemoteMessage> clickedMessage;

  @override
  void initState() {
    super.initState();
    permissionStatus = _setNotificationPermission().toString();
    _saveDeviceoken();

    clickedMessage = handleInitialMessage();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      final snackBar = SnackBar(
        content: Text(message.notification.title),
        action: SnackBarAction(
          label: 'Go',
          onPressed: () => null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final snackBar = SnackBar(
        content: Text(message.notification.title),
        action: SnackBarAction(
          label: 'No',
          onPressed: () => null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Future<String> _setNotificationPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print(
        'User granted permission: ${settings.authorizationStatus.toString()}');
    return settings.authorizationStatus.toString();
  }

  Future<RemoteMessage> handleInitialMessage() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final snackBar = SnackBar(
        content: Text(initialMessage.notification.title),
        action: SnackBarAction(
          label: 'Yay!',
          onPressed: () => null,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return initialMessage;
  }

  _saveDeviceoken() async {
    String userId = 'ishanh';
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = _db
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .doc(fcmToken);

      await tokenRef.set({'token': fcmToken});
      print('========================================Set the token $fcmToken');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(permissionStatus);
  }
}

//https://source.unsplash.com/daily/collection/39384601/400x600
