import 'package:flutter/material.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Counter App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  // 1. Counter တန်ဖိုးကို သိမ်းဆည်းရန် State variable
  int _counter = 0;

  // 2. တန်ဖိုး တိုးပေးသည့် method
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // 3. တန်ဖိုး လျှော့ပေးသည့် method
  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
      }
    });
  }

  // 4. မူလတန်ဖိုး (0) သို့ ပြန်သတ်မှတ်သည့် method
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Counter'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'လက်ရှိ Counter တန်ဖိုး:',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement Button (-)
                FloatingActionButton(
                  heroTag: 'btn_decrement',
                  onPressed: _decrementCounter,
                  tooltip: 'Decrease',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                // Reset Button (0)
                FloatingActionButton(
                  heroTag: 'btn_reset',
                  onPressed: _resetCounter,
                  tooltip: 'Reset',
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 16),
                // Increment Button (+)
                FloatingActionButton(
                  heroTag: 'btn_increment',
                  onPressed: _incrementCounter,
                  tooltip: 'Increase',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}