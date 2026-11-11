import 'package:flutter/material.dart';
import 'package:tutorial/main2.dart';

class Main1 extends StatefulWidget {
  const new({super.key});

  @override
  State<Main1> createState() => _Main1State();
}

class _Main1State extends State<Main1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
Text("first page"),
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Main2(userName: "Aye",age: 12),
      ),
    );
  },
  child: const Text('Go to Second Screen'),
)
    ],));
  }
}
