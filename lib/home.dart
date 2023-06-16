import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pv_charging_app/queue.dart';
import 'const.dart';
import 'log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int balance = 0;
  List<Log> logs = [];

  @override
  void initState() {
    checkBalance();
    super.initState();
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, textAlign: TextAlign.center)));
  }

  Future<void> checkBalance() async {
    String mail = storage.getItem("email");
    String param = "action=balance&email=$mail";
    await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param")).then((resp) async {
      print(resp.body);
      if (resp.body.contains("Error")) {
        return;
      }
      String value = resp.body.replaceAll("Balance: ", "");
      setState(() {
        balance = int.parse(value);
        print(balance);
      });
    });
  }

  Future<bool> isChargerFree(int sid, int cid) async {
    String param = "action=chargerState&station_id=$sid&charger_id=$cid";
    var resp = await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param"));
    if (resp.body.contains("off")) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> userLog() async {
    String uid = storage.getItem("user_id");
    String param = "action=customerQueue&user_id=$uid";
    var resp = await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param"));
    List<dynamic> json = jsonDecode(resp.body);
    logs.clear();
    logs.addAll(json.map((e) => Log.fromMap(e)).toList());
  }

  Widget button(String title, Icon icon, action) {
    return SizedBox(
      width: double.maxFinite,
      height: 100,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        child: InkWell(
          onTap: action,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 20),
              icon,
              const SizedBox(width: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PV Charger Customer"),
        actions: [
          IconButton(
            onPressed: () async {
              await storage.clear();
              await storage.setItem("login", false);
              Navigator.of(context).popAndPushNamed("/login");
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          button(
            "My Balance: $balance BDT",
            const Icon(Icons.monetization_on, color: Colors.greenAccent, size: 60),
            () => checkBalance(),
          ),
          button("Manual", const Icon(Icons.input, color: Colors.purpleAccent, size: 60), () {
            showDialog(
                context: context,
                builder: (context) {
                  var sid = TextEditingController();
                  var cid = TextEditingController();
                  return AlertDialog(
                    content: SizedBox(
                      height: 180,
                      child: Column(
                        children: [
                          TextField(
                            controller: sid,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Station ID"),
                          ),
                          TextField(
                            controller: cid,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Charger ID"),
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                              onPressed: () async {
                                int sidi = int.parse(sid.text);
                                int cidi = int.parse(cid.text);
                                bool chargerAvailable = await isChargerFree(sidi, cidi);
                                if (!chargerAvailable) {
                                  Navigator.pop(context);
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                  showToast("This charger is busy right now!");
                                  return;
                                }
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => QueueScreen(sid: sidi, cid: cidi)),
                                );
                              },
                              child: const Text("Next")),
                        ],
                      ),
                    ),
                  );
                });
          }),
          button("Scan QR", const Icon(Icons.camera_alt, color: Colors.deepOrangeAccent, size: 60), () async {
            var result = await BarcodeScanner.scan();
            if (result.rawContent.contains("C")) {
              int sid = int.parse(result.rawContent[1]);
              int cid = int.parse(result.rawContent[3]);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueueScreen(sid: sid, cid: cid)));
            }
            print(result.rawContent);
          }),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              "Charge History:",
              style: TextStyle(fontSize: 25),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: userLog(),
              builder: (context, data) {
                if (data.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (logs.isEmpty) {
                  return const Center(child: Text("No previous log found!"));
                }

                return ListView(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  children: logs
                      .map(
                        (log) => Card(
                          elevation: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(log.start_time),
                            subtitle: Text("STA: ${log.station_id} | CHA: ${log.charger_id} | ${log.charging_mode}"),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("${log.charge_bill}TK"),
                                Text(log.charge_time == "-1" ? "F.CHA" : "${log.charge_time} min"),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
