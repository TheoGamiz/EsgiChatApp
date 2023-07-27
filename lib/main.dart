import 'package:esgi_chat_app/app/app.dart';
import 'package:esgi_chat_app/app/firebase_api.dart';
import 'package:esgi_chat_app/features/home/screens/home_screen.dart';
import 'package:esgi_chat_app/features/widgets/navbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}
