import './login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final LocalStorage storage = LocalStorage('data');

  void showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = storage.getItem("login") ?? false;
    if (!isLoggedIn) LoginPage();
    return Scaffold(
      appBar: AppBar(
        title: const Text("PV Charger Customer"),
        actions: [
          IconButton(
            onPressed: () {
              storage.clear();
              storage.setItem("login", false);
              Navigator.of(context).popAndPushNamed("/login");
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: FutureBuilder(
        builder: (context, data) {
          return const Center(
            child: Text("Hello"),
          );
        },
      ),
    );
  }
}
