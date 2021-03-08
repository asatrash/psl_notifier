import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_message_handler.dart';

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
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // FirebaseMessaging _fcm = FirebaseMessaging.instance;
  FirebaseMessageHandler _fmh = FirebaseMessageHandler();
  String permissionStatus = ' ';
  Future<RemoteMessage> clickedMessage;
  Future<RemoteMessage> onlineMessage;

  @override
  void initState() {
    super.initState();
    //Set notification settings in iOS. Always set in Android
    permissionStatus =
        FirebaseMessageHandler.setNotificationPermission().toString();
    //Get the device token and save it in Firebase store
    FirebaseMessageHandler.saveDeviceToken();

    //Handling messages received while the app has been terminated
    clickedMessage = FirebaseMessageHandler.handleInitialMessage();
    clickedMessage.then((message) {
      if (clickedMessage != null) {
        final snackBar = SnackBar(
          // content: Text( clickedMessage.notification.title),
          content: Text(message.notification.title),
          action: SnackBarAction(
            label: 'Yay!',
            onPressed: () => null,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });

    //Handling messages received while the app in active on the screen
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

    //Handling messages received while the app is in background but not terminated
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

  @override
  Widget build(BuildContext context) {
    return Text(permissionStatus);
  }
}

//https://source.unsplash.com/daily/collection/39384601/400x600
