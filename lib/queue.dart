import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';

// ignore: must_be_immutable
class QueueScreen extends StatefulWidget {
  int sid, cid;
  QueueScreen({super.key, required this.sid, required this.cid});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  int balance = 0, rate = 0;
  int minUnit = 5, minBill = 0;
  int amount = 50, amountMin = 0;
  bool isFast = true;

  @override
  void initState() {
    checkRate();
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

  Future<void> updateBalance(int bill) async {
    String mail = storage.getItem("email");
    String param = "action=deduct&email=$mail&amount=$bill";
    await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param"));
  }

  Future<void> checkRate() async {
    String param = "action=rate&station_id=${widget.sid}&charger_id=${widget.cid}";
    await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param")).then((resp) async {
      print(resp.body);
      if (resp.body.contains("Rate")) {
        String value = resp.body.replaceAll("Rate: ", "");
        setState(() {
          rate = int.parse(value);
          print(rate);
        });
      }
    });
  }

  Future<void> queue(int time, int bill) async {
    if (bill > balance) {
      showToast("Your balance is insufficient!");
      return;
    }
    String userId = storage.getItem("user_id");
    String param =
        "action=queue&user_id=$userId&station_id=${widget.sid}&charger_id=${widget.cid}&charge_bill=$bill&charge_time=$time&charging_mode=${isFast ? "fast" : "buck"}";
    await http.get(Uri.parse("https://esinebd.com/projects/chargerStation/api.php?$param")).then((resp) async {
      print(resp.body);
      if (resp.body.contains("successfully")) {
        updateBalance(bill);
        showToast("Your charging queue is added.");
      } else {
        showToast("Something went wrong!");
      }
      Navigator.of(context).pop();
    });
  }

  Widget button(String title, Icon icon, action) {
    return SizedBox(
      width: double.maxFinite,
      height: 90,
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

  Widget queueCard() {
    return SizedBox(
      width: double.maxFinite,
      height: 130,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        child: InkWell(
          onTap: () {},
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Full Charge", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Fee: ${isFast ? "1500" : "1000"}TK",
                      style: const TextStyle(fontSize: 22, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 120,
                      child: FilledButton(onPressed: () => queue(-1, isFast ? 1500 : 1000), child: const Text("Buy")),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget queueCardByTime() {
    minBill = rate * minUnit + (isFast ? minUnit * 2 : 0);
    return SizedBox(
      width: double.maxFinite,
      height: 170,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        child: InkWell(
          onTap: () {},
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Charge by Time", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          if (minUnit > 5) minUnit -= 5;
                        });
                      },
                      icon: const Icon(Icons.do_disturb_on),
                    ),
                    Text("${minUnit}min", style: const TextStyle(fontSize: 22, color: Colors.grey)),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          minUnit += 5;
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                    ),
                    Text("Fee: ${minBill}TK", style: const TextStyle(fontSize: 22, color: Colors.grey)),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 120,
                    child: FilledButton(onPressed: () => queue(minUnit, minBill), child: const Text("Buy")),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget queueCardByAmount() {
    if (rate == 0) return const SizedBox.shrink();
    if (isFast) {
      int reduce = amount ~/ 50;
      amountMin = amount ~/ rate - reduce;
    } else {
      amountMin = amount ~/ rate;
    }
    return SizedBox(
      width: double.maxFinite,
      height: 170,
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        child: InkWell(
          onTap: () {},
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Charge by Amount", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          if (amount > 50) amount -= 50;
                        });
                      },
                      icon: const Icon(Icons.do_disturb_on),
                    ),
                    Text("${amount}TK", style: const TextStyle(fontSize: 22, color: Colors.grey)),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          amount += 50;
                        });
                      },
                      icon: const Icon(Icons.add_circle),
                    ),
                    Text("Time: ${amountMin}min", style: const TextStyle(fontSize: 22, color: Colors.grey)),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 120,
                    child: FilledButton(onPressed: () => queue(amountMin, amount), child: const Text("Buy")),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("STA: ${widget.sid} | CHA: ${widget.cid}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            button(
              "My Balance: $balance BDT",
              const Icon(Icons.monetization_on, color: Colors.greenAccent, size: 50),
              () => checkBalance(),
            ),
            button(
              "Fee: $rate BDT/min",
              const Icon(Icons.monetization_on_outlined, color: Colors.orangeAccent, size: 50),
              () => checkRate(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text("Charging Option:", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text("Fast Mode"),
                  selected: isFast,
                  selectedColor: Colors.lightBlueAccent,
                  onSelected: (value) {
                    isFast = value;
                    setState(() {});
                  },
                ),
                ChoiceChip(
                  label: const Text("Buck Mode"),
                  selected: !isFast,
                  selectedColor: Colors.lightBlueAccent,
                  onSelected: (value) {
                    isFast = !value;
                    setState(() {});
                  },
                ),
              ],
            ),
            queueCard(),
            queueCardByTime(),
            queueCardByAmount(),
          ],
        ),
      ),
    );
  }
}
