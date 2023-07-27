import 'dart:convert';

import 'package:esgi_chat_app/features/home/screens/home_screen.dart';
import 'package:esgi_chat_app/features/widgets/navbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> handleMessage(RemoteMessage? message) async {
  if(message == null) return;
  navigatorKey.currentState!.pushNamed(HomeScreen.routeName, arguments: message.data['friendUid']);
}

final _localNotifications = FlutterLocalNotificationsPlugin();


class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message){
      final notification = message.notification;
      if(notification == null) return;

      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
              )
          ),
          payload: jsonEncode(message.toMap())
      );
    });
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('app_icon');
    const settings = InitializationSettings(iOS: iOS, android: android);

    await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (payload) {
          final message = RemoteMessage.fromMap(jsonDecode(payload as String));
          handleMessage(message);
        }
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }


  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    String? token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    initPushNotifications();
    initLocalNotifications();
  }
}