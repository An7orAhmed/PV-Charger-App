import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'const.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PV Charger Customer"),
        actions: [
          IconButton(
            onPressed: () async {
              storage.clear();
              await storage.setItem("login", false);
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
