import 'package:flutter/material.dart';
import 'package:tutorial/main1.dart';

class Main2 extends StatefulWidget {
  final String userName;
  final int age;

  const new({super.key, required this.userName, required this.age});
  

  @override
  State<Main2> createState() => _Main1State();
}

class _Main1State extends State<Main2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
Text("second page"),
Text(widget.userName),
Text(widget.age.toString()),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Main1(),
      ),
    );
  },
  child: const Text('Go to Second Screen'),
)
    ],));
  }
}
