
import 'package:flutter/material.dart';

void main() {
  runApp(const Userinput());
}

class Userinput extends StatelessWidget {
  const Userinput({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Input Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // Controller to read and manage the text in the TextField
  final TextEditingController _textController = TextEditingController();

  // State variable to store and display submitted text
  String _displayedText = 'No input yet';

  void _updateText() {
    setState(() {
      if (_textController.text.trim().isEmpty) {
        _displayedText = 'Please enter some text!';
      } else {
        _displayedText = _textController.text;
      }
    });
  }

  void _clearText() {
    setState(() {
      _textController.clear();
      _displayedText = 'No input yet';
    });
  }

  @override
  void dispose() {
    // Always dispose controllers when the widget is removed from the widget tree
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful User Input'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display container for the submitted text
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _displayedText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Input field
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter something',
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onSubmitted: (_) => _updateText(),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _updateText,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _clearText,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}