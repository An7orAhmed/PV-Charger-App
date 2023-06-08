import './home.dart';
import './login.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

// flutter build apk --release

void main() {
  final LocalStorage storage = LocalStorage('data');
  bool isLoggedIn = storage.getItem("login") ?? false;
  runApp(MaterialApp(
    title: "Charger Station",
    debugShowCheckedModeBanner: false,
    routes: {
      "/": (context) => isLoggedIn ? HomePage() : LoginPage(),
      "/home": (context) => HomePage(),
      "/login": (context) => LoginPage(),
    },
  ));
}
