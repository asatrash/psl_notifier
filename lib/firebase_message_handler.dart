import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessageHandler {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  FirebaseMessaging getInstance() {
    return _fcm;
  }

  static saveDeviceToken() async {
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

  static Future<RemoteMessage> handleInitialMessage() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    return initialMessage;
  }

  static Future<String> setNotificationPermission() async {
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
}
