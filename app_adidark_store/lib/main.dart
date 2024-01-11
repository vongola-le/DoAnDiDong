import 'package:app_adidark_store/Screens/ChiTietHoaDon/ChiTietHoaDon_Screen.dart';
import 'package:app_adidark_store/Screens/Gio_Hang/CartScreen.dart';
import 'package:app_adidark_store/Screens/HoaDon/HoaDon_Screen.dart';
import 'package:app_adidark_store/Screens/SignUp_In/SignInScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Screens/ChiTiet_SanPham/ProDetailScreen.dart';
import 'firebase_options.dart';
import 'Provider/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(fontFamily: "Mulish"),
        home: const HoaDon_Screen(),
        // sdt: 123
        // pas: abc
        debugShowCheckedModeBanner: false,
      ));
}
