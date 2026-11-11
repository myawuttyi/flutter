import 'package:flutter/material.dart';
import 'package:tutorial/counter.dart';
import 'package:tutorial/exc/strawberry.dart';
import 'package:tutorial/main1.dart';
import 'package:tutorial/shop.dart';
//import 'package:tutorial/shop2.dart';
import 'package:tutorial/userform.dart';
import 'package:tutorial/userinput.dart';
//import 'package:tutorial/shop.dart';

class MyWidget1 extends StatefulWidget {
  const new({super.key});

  @override
  State<MyWidget1> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget1> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 9,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flight)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_car)),
              Tab(icon:Icon(Icons.local_florist, size:30),text: "Strawberry",),
              Tab(icon: Icon(Icons.assignment, size: 30),text: "Form"),
              Tab(icon:Icon(Icons.input, size: 30),text: "UserInput"),
              Tab(icon:Icon(Icons.dashboard, size: 30),text: "SecondPage"),
              Tab(icon:Icon(Icons.shopping_cart, size: 30),text: "Shopping"),
              Tab(icon:Icon(Icons.add_circle, size: 30),text: "Counter"),
            ],
          ),
          title: Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.flight, size: 350),
            Icon(Icons.directions_transit, size: 350),
           Icon(Icons.directions_car, size: 350),
           Strawberry(),
           MyFormPage(),
           Userinput(),
           Main1(),
           ShoppingApp(),
           CounterApp(),

          ],
        ),
      ),
    );
  }
}