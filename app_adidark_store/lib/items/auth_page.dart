import 'package:app_adidark_store/views/SignUp_In/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'BottomMenu.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return const BottomMenu();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Something Went Wrong !'));
          } else {
            return const Login_Screen();
          }
        },
      ),
    );
  }
}
