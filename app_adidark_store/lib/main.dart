import 'package:app_adidark_store/view/notification_screen.dart';
import 'package:app_adidark_store/view/profile_screen.dart';
import 'package:app_adidark_store/view/setting_screen.dart';
import 'package:app_adidark_store/view/success_fail_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ProfileScreen(
          name: "Hào Lý",
          email: "haoly012345@gmail.com",
          img: "https://avatars.githubusercontent.com/u/134797173?v=4"),
      // home: const SettingScreen(),
      // home: const NotificationScreen(),
      // home: const SuccessFailScreen(state: true),
    );
  }
}
