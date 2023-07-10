import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'const.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void showToast(String message) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
  }

  void login(context, String mail, String pass) async {
    if (mail == '' || pass == '') {
      showToast("Email or Password shouldn't be empty!");
      return;
    }
    String param = "action=login&user_type=user&email=$mail&password=$pass";
    await http.get(Uri.parse("${host}api.php?$param")).then((resp) async {
      print(resp.body);
      if (resp.body.contains("failed")) {
        showToast("Email or password not found!");
        return;
      }
      var userId = resp.body.replaceAll("Login successful. User ID: ", "");
      await storage.setItem("login", true);
      await storage.setItem("email", mail);
      await storage.setItem("pass", pass);
      await storage.setItem("user_id", userId);
      print("$mail, $pass, $userId");
      Navigator.of(context).pushReplacementNamed("/home");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 320,
          child: Card(
            elevation: 35,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "PV Charger Customer",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w200),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text;
                      String pass = _passwordController.text;
                      login(context, email, pass);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
