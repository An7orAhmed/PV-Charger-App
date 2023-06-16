import './home.dart';
import './login.dart';
import 'package:flutter/material.dart';
import 'const.dart';

// flutter build apk --release
void main() {
  bool isLoggedIn = storage.getItem("login") ?? false;
  runApp(MaterialApp(
    title: "Charger Station",
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => isLoggedIn ? const HomePage() : LoginPage(),
      "/home": (context) => const HomePage(),
      "/login": (context) => LoginPage(),
    },
  ));
}
