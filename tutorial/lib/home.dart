import 'package:flutter/material.dart';
import 'package:tutorial/exc/strawberry.dart';
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flight)),
              Tab(icon: Icon(Icons.directions_transit)),
              Tab(icon: Icon(Icons.directions_car)),
            ],
          ),
          title: Text('Tabs Demo'),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.flight, size: 350),
            Icon(Icons.directions_transit, size: 350),
           MyWidget(),
          ],
        ),
      ),
    );
  }
}