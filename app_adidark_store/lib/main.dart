import 'package:app_adidark_store/items/ItemLocalNotification.dart';
import 'package:app_adidark_store/views/Gio_Hang/CartScreen.dart';
import 'package:app_adidark_store/views/SignUp_In/respository/Authentication_Repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationAPI.initializaLocalNotifications();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(Auth_Resposity()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.blue, fontFamily: "Mulish"),
      home: const CartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
